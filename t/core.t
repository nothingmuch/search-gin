#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::TempDir;

{
    # this will be a default class, for now I'm keeping them separate
    package MyGIN;
    use Moose;

    # in memory index:
    #with qw(
    #   Search::GIN::AwareObjects
    #   Search::GIN::Driver::Hash
    #);

    # on disk index:
    with qw(
        Search::GIN::AwareObjects
        Search::GIN::Driver::BerkeleyDB
        Search::GIN::Driver::PackUUID
    );

    # the only required method left after all these roles were added
    # we fake it here, but it should go to the storage backend
    sub ids_to_objects {
        my ( $self, @ids ) = @_;
        @{ $self->objects }{@ids};
    }

    around objects_to_ids => sub {
        my ( $next, $self, @objs ) = @_;
        my @ids = $self->$next(@objs);
        @{ $self->objects }{@ids} = @objs;
        return @ids;
    };

    has objects => (
        isa => "HashRef",
        is  => "rw",
        default => sub { {} },
    );

    # you create the query objects, the GIN implementation uses them
    # consistently with the index
    package MyTagQuery;
    use Moose::Role;

    use MooseX::Types::Set::Object;

    with qw(Search::GIN::Query);

    has tags => (
        isa => "Set::Object",
        is  => "ro",
        coerce   => 1,
        required => 1,
    );

    sub gin_extract_values {
        my $self = shift;
        $self->tags->members;
    }

    package MyTagQuery::Intersection;
    use Moose;

    with qw(MyTagQuery);

    sub gin_consistent {
        my ( $self, $item ) = @_;
        return $item->tags->superset($self->tags);
    }

    package MyTagQuery::Union;
    use Moose;

    with qw(MyTagQuery);

    sub gin_consistent {
        my ( $self, $item ) = @_;
        return $self->tags->intersection($item->tags)->size >= 1;
    }


    # this is an indexable object
    package MyObject;
    use Moose;

    use MooseX::Types::Set::Object;

    with qw(Search::GIN::Indexable);

    has id => (
        isa => "Str",
        is  => "ro",
    );

    sub gin_id { shift->id }

    has tags => (
        isa => "Set::Object",
        is  => "ro",
        coerce  => 1,
        default => sub { Set::Object->new },
    );

    sub gin_extract_values {
        my $self = shift;
        $self->tags->members;
    }

    sub gin_compare_values {
        my ( $self, $one, $two ) = @_;
        $one cmp $two;
    }
}


my $gin = MyGIN->new(
    home => temp_root,
    file => "foo.idx",
);

my @objs = map { MyObject->new(%$_) } (
    {
        id   => "aaaaaaaaaaaaaaaa",
        tags => [ qw(foo bar baz donkey) ],
    },
    {
        id   => "aaaaaaaaaaaaaaab",
        tags => [ qw(bar gorch baz) ],
    },
    {
        id   => "aaaaaaaaaaaaaaac",
        tags => [ qw(zot urf donkey gorch) ],
    },
);

$gin->insert(@objs);

{
    my @res = $gin->query( MyTagQuery::Intersection->new( tags => [qw(foo)] ) );
    is_deeply( [ @res ], [ $objs[0] ] );
}

{
    my @res = $gin->query( MyTagQuery::Union->new( tags => [qw(foo)] ) );
    is_deeply( [ @res ], [ $objs[0] ] );
}

{
    my @res = $gin->query( MyTagQuery::Intersection->new( tags => [qw(bar)] ) );
    is_deeply( [ sort @res ], [ sort @objs[0, 1] ] );
}

{
    my @res = $gin->query( MyTagQuery::Intersection->new( tags => [qw(gorch)] ) );
    is_deeply( [ sort @res ], [ sort @objs[1, 2] ] );
}

{
    my @res = $gin->query( MyTagQuery::Intersection->new( tags => [qw(bar gorch)] ) );
    is_deeply( [ @res ], [ $objs[1] ] );
}

{
    my @res = $gin->query( MyTagQuery::Union->new( tags => [qw(bar gorch)] ) );
    is_deeply( [ sort @res ], [ sort @objs ] );
}

