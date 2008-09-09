#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Search::GIN::Query::Class';

{
    package MyGIN;
    use Moose;

    with (
        qw(
            Search::GIN::Core
            Search::GIN::Driver::Hash
            Search::GIN::SelfIDs
            Search::GIN::Extract::Class
        ),
    );

    __PACKAGE__->meta->make_immutable;

    # this is an indexable object
    package Base;
    use Moose;

    __PACKAGE__->meta->make_immutable;

    package Foo;
    use Moose;

    extends qw(Base);

    __PACKAGE__->meta->make_immutable;

    package Bar;
    use Moose;

    extends qw(Base);

    __PACKAGE__->meta->make_immutable;

    package Gorch;
    use Moose;

    extends qw(Bar);

    __PACKAGE__->meta->make_immutable;
}


my $gin = MyGIN->new();

my @objs = (
    Base->new,
    Foo->new,
    Bar->new,
    Bar->new,
    Gorch->new,
);

$gin->insert(undef, @objs);

{
    my @res = $gin->query( undef, Search::GIN::Query::Class->new( class => "Base" ) )->all;
    is_deeply( [ sort @res ], [ sort @objs ] );
}

{
    my @res = $gin->query( undef, Search::GIN::Query::Class->new( class => "Foo" ) )->all;
    is_deeply( [ @res ], [ $objs[1] ] );
}

{
    my @res = $gin->query( undef, Search::GIN::Query::Class->new( class => "Bar" ) )->all;
    is_deeply( [ sort @res ], [ sort @objs[2, 3, 4] ] );
}



