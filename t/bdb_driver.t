#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::TempDir;

use Path::Class;

use ok 'Search::GIN::Driver::BerkeleyDB';

{
    package Drv;
    use Moose;

    with qw(Search::GIN::Driver::BerkeleyDB Search::GIN::Driver::PackUUID);
}

my $d = Drv->new( file => "foo.idx", home => temp_root );

my $id = "a" x 16;
my @ids = map { $id++ } 1 .. 10;

my @foo = @ids[3,4,6];
my @bar = @ids[4,8];

$d->insert_entries({
    foo => \@foo,
    bar => \@bar,
});

is_deeply( [ sort $d->fetch_entry('foo') ], [ sort @foo ], "foo entry" );
is_deeply( [ sort $d->fetch_entry('bar') ], [ sort @bar ], "bar entry" );

$d->insert_entries({
    foo => [ @ids[1,2] ],
});

is_deeply( [ sort $d->fetch_entry('foo') ], [ sort @foo, @ids[1,2] ], "merged" );

my $txn = $d->txn_begin;

$d->insert_entries({
    quxx => [ $ids[5] ],
});

is_deeply( [ $d->fetch_entry('quxx') ], [ $ids[5] ], "mid txn" );

$d->txn_commit($txn);

is_deeply( [ $d->fetch_entry('quxx') ], [ $ids[5] ], "txn succeeded" );

eval {
    $d->txn_do(sub {
        $d->insert_entries({
            gorch => [ $ids[0] ],
        });

        is_deeply( [ $d->fetch_entry("gorch") ], [ $ids[0] ], "mid txn" );

        die "user error";
    });
};

like( $@, qr/user error/, "got error" );

{
    local $TODO = "txns not implemented yet";
    is_deeply( [ $d->fetch_entry("gorch") ], [ ], "transaction aborted" );
}

$d->txn_do(sub {
    $d->insert_entries({
        zot => [ $ids[5] ],
    });
});

is_deeply( [ $d->fetch_entry("zot") ], [ $ids[5] ], "transaction succeeded" );

$d->remove_entries({
    foo => [ @ids[2,4] ],
});

is_deeply( [ sort $d->fetch_entry('foo') ], [ sort @ids[1, 3, 6] ], "removed" );


