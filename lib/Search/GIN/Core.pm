#!/usr/bin/perl

package Search::GIN::Core;
use Moose::Role;

use Data::Stream::Bulk::Util qw(bulk unique);

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

requires qw(
    objects_to_ids
    ids_to_objects

    extract_values
);

has distinct => (
    isa => "Bool",
    is  => "rw",
    default => 0, # FIXME what should the default be?
);

sub query {
    my ( $self, $c, $query, @args ) = @_;

    my %args = (
        distinct => $self->distinct,
        @args,
    );

    my @spec = $query->extract_values($c);

    my $ids = $self->fetch_entries( $c, @spec );

    $ids = unique($ids) if $args{distinct};

    return $ids->filter(sub { [ grep { $query->consistent($self, $c, $_) } $self->ids_to_objects( $c, @$_ ) ] });
}

__PACKAGE__

__END__
