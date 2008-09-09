#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Search::GIN::Query::Attributes';

{
    package MyGIN;
    use Moose;

    with (
        qw(
            Search::GIN::Core
            Search::GIN::Driver::Hash
            Search::GIN::SelfIDs
            Search::GIN::Extract::Attributes
        ),
    );

    __PACKAGE__->meta->make_immutable;

    package Foo;
    use Moose;

    has age => (
        isa => "Int",
        is  => "rw",
    );

    has name => (
        isa => "Str",
        is  => "rw",
    );

    __PACKAGE__->meta->make_immutable;
}


my $gin = MyGIN->new;

my @objs = ( map { Foo->new($_) } { name => "stevan", age => 47 }, { name => "jon", age => 2 }, { name => "yuval", age => 2 } );

$gin->insert( undef, @objs);

{
    my @res = $gin->query( undef, Search::GIN::Query::Attributes->new( attributes => {} ) )->all;
    is_deeply( \@res, [ ] );
}

{
    my @res = $gin->query( undef, Search::GIN::Query::Attributes->new( attributes => { name => "jon" } ) )->all;
    is_deeply( \@res, [ $objs[1] ] );
}

{
    my @res = $gin->query( undef, Search::GIN::Query::Attributes->new( attributes => { age => 2 } ) )->all;
    is_deeply( [ sort @res ], [ sort @objs[1,2] ] );
}


