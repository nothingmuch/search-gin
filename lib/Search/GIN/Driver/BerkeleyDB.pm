#!/usr/bin/perl

package Search::GIN::Driver::BerkeleyDB;
use Moose::Role;

use Data::Stream::Bulk::Util qw(bulk nil);
use Data::Stream::Bulk::Callback;
use Scalar::Util qw(weaken);
use Scope::Guard;

use constant USE_PARTIAL => 1; # not sure it's a good thing yet

use MooseX::Types::Path::Class;

use BerkeleyDB 0.35; # DBT_MULTIPLE, see http://rt.cpan.org/Ticket/Display.html?id=38896

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Driver::TXN
    Search::GIN::Driver::Pack::Values
);

has home => (
    isa => "Path::Class::Dir",
    is  => "ro",
    coerce   => 1,
    required => 1,
);

has primary_file => (
    isa => "Path::Class::File",
    is  => "ro",
    coerce  => 1,
    default => sub { Path::Class::File->new("primary.db") },
);

has secondary_file => (
    isa => "Path::Class::File",
    is  => "ro",
    coerce  => 1,
    default => sub { Path::Class::File->new("secondary.db") },
);

has env => (
    isa => "BerkeleyDB::Env",
    is  => "ro",
    lazy_build => 1,
);

sub _build_env {
    my $self = shift;

    BerkeleyDB::Env->new(
        -Home  => $self->home,
        -Flags => DB_CREATE | DB_INIT_MPOOL | DB_REGISTER | DB_RECOVER | DB_INIT_TXN,
    );
}

has [qw(primary_db secondary_db)] => (
    isa => "Object",
    is  => "ro",
    lazy_build => 1,
);

has block_size => (
    isa => "Int",
    is  => "rw",
    default => 500,
);

sub _build_primary_db {
    my $self = shift;

    my $primary = $self->open_db( $self->primary_file );

    my $secondary = $self->secondary_db;

    my $weak_self = $self;
    weaken($weak_self); # don't leak (circular ref)

    if( $primary->associate( $secondary, sub {
        my ( $id, $vals ) = @_;
        $_[2] = [ $weak_self->unpack_values($vals) ]; # YUCK WE HATES IT!!!

        return 0;
    } ) != 0 ) {
        die $BerkeleyDB::Error;
    }

    return $primary;
}

# this is the secondary index, it maps from secondary keys (the inverted values) back to IDS
# BDB maintains (as in updates/deletes etc) entries from this index based on
# modifications to primary_db
sub _build_secondary_db {
    my $self = shift;
    $self->open_db( $self->secondary_file, -Property => DB_DUP|DB_DUPSORT );
}

sub open_db {
    my ( $self, $file, @args ) = @_;

    BerkeleyDB::Btree->new( # FIXME allow hash too?
        -Env      => $self->env,
        -Filename => $file,
        -Flags    => DB_CREATE|DB_AUTO_COMMIT, # autocommit allows us to work with or without txn_begin
        -Txn      => undef,
        @args,
    ) || die $BerkeleyDB::Error;
}

# base methods for the TXN role
sub txn_begin {
    my ( $self, $parent_txn ) = @_;

    my $txn = $self->env->TxnMgr->txn_begin($parent_txn || ());

    $txn->Txn($self->primary_db, $self->secondary_db);

    return $txn;
}

sub txn_commit {
    my ( $self, $txn ) = @_;

    unless ( $txn->txn_commit == 0 ) {
        die $BerkeleyDB::Error;
    }
}

sub txn_rollback {
    my ( $self, $txn ) = @_;
    
    unless ( $txn->txn_abort == 0 ) {
        die $BerkeleyDB::Error;
    }
}

# Search::GIN::Driver methods
sub fetch_entry {
    my ( $self, $key ) = @_;
    $self->get_ids($key);
}

sub remove_ids {
    my ( $self, @ids ) = @_;

    my $pri = $self->primary_db;

    # BDB will delete all dependent keys from the secondary index
    foreach my $id ( @ids ) {
        $pri->db_del($id);
    }
}

sub insert_entry {
    my ( $self, $id, @keys ) = @_;

    my $pri = $self->primary_db;

    # BDB will update the secondary index using the callback we gave it in
    # ->associate
    $pri->db_put($id, $self->pack_values(@keys));
}

# this method is just for completeness
sub get_values {
    my ( $self, $id ) = @_;

    my $v;

    if ( $self->primary_db->db_get( $id, $v ) == 0 ) {
        return $self->unpack_values($v);
    } else {
        return;
    }
}

# OW MY EYES! BDB is so nastty it's not even funny.

# to avoid reading key data unnecessarily (we'll never actually need it) we set
# the partial value range to
sub _key_only_guard ($) {
    my $db = shift;

    my ( $pon, $off, $len ) = $db->partial_set(0,0);

    return Scope::Guard->new(sub {
        if ( $pon ) {
            $db->partial_set($off, $len);
        } else {
            $db->partial_clear;
        }
    });
}

# this data set is potentially large (all IDs for a given secondary key)
# we iterate the duplicates, and if we wind up with more than $block_size then
# we create an iterator for the remainder
sub get_ids {
    my ( $self, $key ) = @_;

    my $db = $self->secondary_db;

    my $g = USE_PARTIAL && _key_only_guard($db);

    my $cursor = $db->db_cursor;

    my @matches;

    my ( $pk, $v );

    if ( $cursor->c_pget( $key, $pk, $v, DB_SET ) == 0 ) {
        push @matches, $pk;

        $cursor->c_count(my $cnt);

        if ( $cnt > 1 ) { # more entries for the same value
            my $block_size = $self->block_size;

            # fetch up to one block
            for ( 1 .. $block_size-1 ) {
                if ( $cursor->c_pget( $key, $pk, $v, DB_NEXT_DUP ) == 0 ) {
                    push @matches, $pk;
                } else {
                    return bulk(@matches);
                }
            }

            # and defer the rest
            return bulk(@matches)->cat( $self->_iter_read_cursor( $key, $db, $cursor, $block_size) );
        }
    }

    return bulk(@matches);
}

# creates a Data::Stream::Bulk out of a BDB iterator
sub _iter_read_cursor {
    my ( $self, $key, $db, $cursor, $block_size ) = @_;

    Data::Stream::Bulk::Callback->new(
        callback => sub {
            my ( $pk, $v, @matches );

            return unless $cursor;

            # sets up partial_set/partial_clear if enabled
            my $g = USE_PARTIAL && _key_only_guard($db);

            for ( 1 .. $block_size ) {
                if ( $cursor->c_pget( $key, $pk, $v, DB_NEXT_DUP ) == 0 ) {
                    push @matches, $pk;
                } else {
                    # we're done, this is the last block
                    undef $cursor;
                    return ( scalar(@matches) && \@matches );
                }
            }

            return \@matches;
        },
    );
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::BerkeleyDB - 

=head1 SYNOPSIS

    use Search::GIN::Driver::BerkeleyDB;

=head1 DESCRIPTION

=cut


