#!/usr/bin/perl

package Search::GIN::Driver::BerkeleyDB;
use Moose::Role;

use Set::Object qw(set);

use MooseX::Types::Path::Class;

use List::MoreUtils qw(uniq);

use BerkeleyDB;

# FIXME http://www.oracle.com/technology/documentation/berkeley-db/db/ref/am/second.html

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Driver::TXN
    Search::GIN::Driver::Pack
);

has home => (
    isa => "Path::Class::Dir",
    is  => "ro",
    coerce   => 1,
    required => 1,
);

has file => (
    isa => "Path::Class::File",
    is  => "ro",
    coerce   => 1,
    required => 1,
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

has db => (
    isa => "BerkeleyDB::Hash",
    is  => "ro",
    lazy_build => 1,
    handles => [qw(db_get db_put db_del)],
);

sub _build_db {
    my $self = shift;

    BerkeleyDB::Hash->new(
        -Env      => $self->env,,
        -Filename => $self->file,
        -Flags    => DB_CREATE,
        -Txn      => undef,
        #-Property => DB_DUP,
    );
}

# FIXME nested transactions
sub txn_begin {
    my $self = shift;

    my $txn = $self->env->TxnMgr->txn_begin;

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

    foreach my $id ( @ids ) {
        my $key_set = $self->get_values($id) || next;
        $self->put_values($id, ());

        foreach my $key ( $key_set->members ) {
            my $set = $self->get_ids($key) || next;
            $set->remove(@ids);
            $self->put_ids($key, $set);
        }
    }
}

sub insert_entry {
    my ( $self, $id, @keys ) = @_;

    $self->remove_ids($id);
    $self->put_values($id, @keys); 

    foreach my $key (@keys) {
        my $set = $self->get_ids($key) || set();
        $set->insert($id);
        $self->put_ids($key, $set);
    }
}

sub get_values {
    my ( $self, $id ) = @_;

    if ( $self->db_get("id:$id", my $value) == 0) {
        return $self->unpack_values($value);
    } else {
        return;
    }
}

sub put_values {
    my ( $self, $id, @keys ) = @_;

    my $key_str = "id:$id";

    if ( @keys ) {
        $self->db_put($key_str, $self->pack_values(set(@keys)));
    } else {
        $self->db_del($key_str);
    }
}

sub get_ids {
    my ( $self, $key ) = @_;

    if ( $self->db_get("key:$key", my $value) == 0) {
        return $self->unpack_ids($value);
    } else {
        return;
    }
}

sub put_ids {
    my ( $self, $key, $ids ) = @_;
    
    my $key_str = "key:$key";

    if ( $ids->size ) {
        $self->db_put($key_str, $self->pack_ids($ids));
    } else {
        $self->db_del($key_str);
    }
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


