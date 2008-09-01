#!/usr/bin/perl

package Search::GIN::Driver::BerkeleyDB;
use Moose::Role;

use Set::Object qw(set);
use Scalar::Util qw(weaken);
use List::MoreUtils qw(uniq);

use MooseX::Types::Path::Class;

use BerkeleyDB 0.35; # DBT_MULTIPLE

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
        -Flags => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL|DB_INIT_LOCK,
    );
}

has [qw(primary_db secondary_db)] => (
    isa => "Object",
    is  => "ro",
    lazy_build => 1,
);

sub _build_primary_db {
    my $self = shift;

    my $primary = $self->open_db( $self->primary_file );

    my $secondary = $self->secondary_db;

    my $weak_self = $self;
    weaken($weak_self);

    if( $primary->associate( $secondary, sub {
        my ( $id, $vals ) = @_;
        my $v = $weak_self->unpack_values($vals);

        $_[2] = [ $v->members ];

        return 0;
    } ) != 0 ) {
        die $BerkeleyDB::Error;
    }

    return $primary;
}

sub _build_secondary_db {
    my $self = shift;
    $self->open_db( $self->secondary_file, -Property => DB_DUP|DB_DUPSORT );
}

sub open_db {
    my ( $self, $file, @args ) = @_;

    BerkeleyDB::Btree->new(
        -Env      => $self->env,
        -Filename => $file,
        -Flags    => DB_CREATE|DB_AUTO_COMMIT,
        -Txn      => undef,
        @args,
    );
}

sub txn_begin {
    my ( $self, @args ) = @_;

    my $txn = $self->env->TxnMgr->txn_begin(@args);

    $txn->Txn($self->primary_db, $self->secondary_db);

    return $txn;
}

sub txn_commit {
    my ( $self, $txn ) = @_;

    unless ( $txn->txn_commit == 0 ) {
        die "txn commit failed";
    }
}

sub txn_rollback {
    my ( $self, $txn ) = @_;
    
    unless ( $txn->txn_abort == 0 ) {
        die "txn abort failed";
    }
}

sub fetch_entry {
    my ( $self, $key ) = @_;
    $self->get_ids($key);
}

sub remove_ids {
    my ( $self, @ids ) = @_;

    my $pri = $self->primary_db;

    foreach my $id ( @ids ) {
        $pri->db_del($id);
    }
}

sub insert_entry {
    my ( $self, $id, @keys ) = @_;

    my $pri = $self->primary_db;

    $pri->db_put($id, $self->pack_values(set(@keys)));
}

sub get_values {
    my ( $self, $id ) = @_;

    my $v;

    if ( $self->primary_db->db_get( $id, $v ) == 0 ) {
        return set($self->unpack_values($v));
    } else {
        return;
    }
}

sub get_ids {
    my ( $self, $key ) = @_;

    my $cursor = $self->secondary_db->db_cursor;

    my @matches;

    my ( $pk, $v );

    if ( $cursor->c_pget( $key, $pk, $v, DB_SET ) == 0 ) {
        push @matches, $pk;
        while ( $cursor->c_pget( $key, $pk, $v, DB_NEXT_DUP ) == 0 ) {
            push @matches, $pk;
        }
    }

    return set(@matches);
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


