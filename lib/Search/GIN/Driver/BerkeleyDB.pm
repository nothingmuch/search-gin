#!/usr/bin/perl

package Search::GIN::Driver::BerkeleyDB;
use Moose::Role;


use Scalar::Util qw(weaken);

use MooseX::Types::Path::Class;

use BerkeleyDB 0.35; # DBT_MULTIPLE, see http://rt.cpan.org/Ticket/Display.html?id=38896
use BerkeleyDB::Manager;

use constant USE_PARTIAL => 1; # not sure it's a good thing yet

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

has manager => (
    isa => "BerkeleyDB::Manager",
    is  => "ro",
    lazy_build => 1,
    # handles => "Search::GIN::Driver::TXN",
);

sub _build_manager {
    my $self = shift;

    BerkeleyDB::Manager->new(
        home => $self->home,
    );
}

sub txn_begin { shift->manager->txn_begin(@_) }
sub txn_commit { shift->manager->txn_commit(@_) }
sub txn_rollback { shift->manager->txn_rollback(@_) }
sub txn_do { shift->manager->txn_do(@_) }

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

    my $m = $self->manager;

    my $primary = $m->open_db( name => "primary", file => $self->primary_file );

    my $secondary = $self->secondary_db;

    my $weak_self = $self;
    weaken($weak_self); # don't leak (circular ref)

    $m->associate(
        primary => $primary,
        secondary => $secondary,
        callback => sub {
            my ( $id, $vals ) = @_;
            return [ $weak_self->unpack_values($vals) ];
        },
    );

    return $primary;
}

# this is the secondary index, it maps from secondary keys (the inverted values) back to IDS
# BDB maintains (as in updates/deletes etc) entries from this index based on
# modifications to primary_db
sub _build_secondary_db {
    my $self = shift;

    $self->manager->open_db( name => "secondary", file => $self->secondary_file, dup => 1, dupsort => 1 );
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

    my ( $pk, $v );

    $self->manager->dup_cursor_stream(
        db   => $db,
        init => USE_PARTIAL && sub { _key_only_guard($db) },
        callback_first => sub {
            my ( $cursor, $ret ) = @_;

            if ( $cursor->c_pget( $key, $pk, $v, DB_SET ) == 0 ) {
                push @$ret, $pk;
                return 1;
            } else {
                return;
            }
        },
        callback => sub {
            my ( $cursor, $ret ) = @_;

            if ( $cursor->c_pget( $key, $pk, $v, DB_NEXT_DUP ) == 0 ) {
                push @$ret, $pk;
                return 1;
            } else {
                return;
            }
        }
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


