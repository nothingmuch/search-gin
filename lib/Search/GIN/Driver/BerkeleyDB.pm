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
    handles => [qw(db_cursor db_put db_del)],
);

sub _build_db {
    my $self = shift;

    BerkeleyDB::Hash->new(
        -Env      => $self->env,,
        -Filename => $self->file,
        -Flags    => DB_CREATE,
        -Txn      => undef,
        -Property => DB_DUP,
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

        $self->db_del("id:$id");

        # FIXME can we use the fact these are sorted to do a binary search?
        my $v;
        foreach my $key ( $key_set->members ) {
            my $c = $self->db_cursor;
            if ( $c->c_get("key:$key", $v, DB_SET) == 0 ) {
                if ( $v eq $id ) {
                    $c->c_del;
                } else {
                    while( $c->c_get("key:$key", $v, DB_NEXT_DUP) == 0 ) {
                        if ( $v eq $id ) {
                            $c->c_del;
                            last;
                        }
                    }
                }
            }
        }
    }
}

sub insert_entry {
    my ( $self, $id, @keys ) = @_;

    $self->remove_ids($id);

    foreach my $key (@keys) {
        $self->db_put("key:$key", $id);
        $self->db_put("id:$id", $key);
    }
}

sub get_values {
    my ( $self, $id ) = @_;

    my $db_key = "id:$id";
    my $v;

    my $cursor = $self->db_cursor;
    my @matches;
    
    if ( $cursor->c_get( $db_key, $v, DB_SET ) == 0 ) {
        push @matches, $v;
        while ( $cursor->c_get($db_key, $v, DB_NEXT_DUP) == 0 ) {
            push @matches, $v;
        }
    }

    return set(@matches);
}

sub get_ids {
    my ( $self, $key ) = @_;

    my $db_key = "key:$key";
    my $v;

    my $cursor = $self->db_cursor;
    my @matches;

    if ( $cursor->c_get( $db_key, $v, DB_SET ) == 0 ) {
        push @matches, $v;
        while ( $cursor->c_get($db_key, $v, DB_NEXT_DUP) == 0 ) {
            push @matches, $v;
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


