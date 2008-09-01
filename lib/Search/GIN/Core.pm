#!/usr/bin/perl

package Search::GIN::Core;
use Moose::Role;

use Data::Stream::Bulk::Util qw(bulk);
use List::MoreUtils qw(uniq);

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
    my ( $self, $query, @args ) = @_;

    my %args = (
        distinct => $self->distinct,
        @args,
    );

    my @spec = $query->extract_values;

    my $set = $self->fetch_entries(@spec);

    my @ids = $set->all; # FIXME iterate unless ->loaded

    @ids = uniq(@ids) if $args{distinct};

    my @candidate_objs = $self->ids_to_objects(@ids);

    return bulk(grep { $query->consistent($self, $_) } @candidate_objs);
}

__PACKAGE__

__END__
