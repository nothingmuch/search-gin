#!/usr/bin/perl

package Search::GIN::Core;
use Moose::Role;

use Data::Stream::Bulk::Util qw(bulk unique);

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Driver
    Search::GIN::Extract
);

requires qw(
    objects_to_ids
    ids_to_objects
);

has distinct => (
    isa => "Bool",
    is  => "rw",
    default => 0, # FIXME what should the default be?
);

sub query {
    my ( $self, $query, @args ) = @_;

    my %args = (
        distinct => $self->distinct,
        @args,
    );

    my @spec = $query->extract_values($self);

    my $ids = $self->fetch_entries(@spec);

    $ids = unique($ids) if $args{distinct};

    return $ids->filter(sub { [ grep { $query->consistent($self, $_) } $self->ids_to_objects(@$_) ] });
}

sub remove {
    my ( $self, @items ) = @_;

    my @ids = $self->objects_to_ids(@items);

    $self->remove_ids(@ids);
}

sub insert {
    my ( $self, @items ) = @_;

    my @ids = $self->objects_to_ids(@items);

    my @entries;

    foreach my $item ( @items ) {
        my @keys = $self->extract_values( $item, gin => $self );
        my $id = shift @ids;

        $self->insert_entry( $id, @keys );
    }
}

__PACKAGE__

__END__
