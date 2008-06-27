#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::TempDir;

{
    package MyGIN;
    use Moose;

    with (
        qw(
            Search::GIN::Driver::Hash
            Search::GIN::SelfIDs
        ),
        'Search::GIN::AwareObjects' => { excludes => [qw(objects_to_ids)] },
    );

    # you create the query objects, the GIN implementation uses them
    # consistently with the index
    package IsaQuery;
    use Moose;

    with qw(Search::GIN::Query);

    has class => (
        isa => "ClassName",
        is  => "ro",
        required => 1,
    );

    sub gin_extract_values {
        my $self = shift;
        $self->class;
    }

    sub gin_consistent {
        my ( $self, $index, $item ) = @_;
        $item->isa($self->class);
    }

    __PACKAGE__->meta->make_immutable;

    # this is an indexable object
    package Base;
    use Moose;

    with qw(Search::GIN::Indexable);

    sub gin_extract_values {
        my $self = shift;
        $self->meta->linearized_isa;
    }

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


my $gin = MyGIN->new(
    home => temp_root,
    file => "foo.idx",
);

my @objs = (
    Base->new,
    Foo->new,
    Bar->new,
    Gorch->new,
);

$gin->insert(@objs);

{
    my @res = $gin->query( IsaQuery->new( class => "Base" ) );
    is_deeply( [ sort @res ], [ sort @objs ] );
}

{
    my @res = $gin->query( IsaQuery->new( class => "Foo" ) );
    is_deeply( [ @res ], [ $objs[1] ] );
}

{
    my @res = $gin->query( IsaQuery->new( class => "Bar" ) );
    is_deeply( [ sort @res ], [ sort @objs[2, 3] ] );
}



