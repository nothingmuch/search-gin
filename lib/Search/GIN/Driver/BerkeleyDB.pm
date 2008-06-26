#!/usr/bin/perl

package Search::GIN::Driver::BerkeleyDB;
use Moose::Role;

use Set::Object qw(set);

use MooseX::Types::Path::Class;

use List::MoreUtils qw(uniq);

use BerkeleyDB;

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
    );
}

# FIXME nested transactions
sub txn_begin {
    return;
    my $self = shift;

    my $txn = $self->env->TxnMgr->txn_begin;

    $self->db->Txn($txn);

    return $txn;
}

sub txn_commit {
    return;
    my ( $self, $txn ) = @_;

    unless ( $txn->txn_commit == 0 ) {
        die "txn commit failed";
    }

    $self->db->Txn(undef);
}

sub txn_rollback {
    return;
    my ( $self, $txn ) = @_;

    warn "Aborting";

    unless ( $txn->txn_abort == 0 ) {
        die "txn abort failed";
    }

    $self->db->Txn(undef);
}

sub fetch_entry {
    my ( $self, $key ) = @_;
    @{ $self->get_ids($key) };
}

sub remove_ids {
    my ( $self, $key, $ids ) = @_;

    my $set = $self->get_ids($key);

    $set->remove(@$ids);

    $self->put_ids($key, $set);
}

sub insert_ids {
    my ( $self, $key, $ids ) = @_;

    my $set = $self->get_ids($key);

    $set->insert(@$ids);

    $self->put_ids($key, $set);
}

sub get_ids {
    my ( $self, $key ) = @_;

    if ( $self->db_get($key, my $value) == 0) {
        return $self->unpack_ids($value);
    } else {
        return set();
    }
}

sub put_ids {
    my ( $self, $key, $ids ) = @_;

    if ( @$ids ) {
        $self->db_put($key, $self->pack_ids($ids));
    } else {
        $self->db_del($key);
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


