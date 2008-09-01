#!/usr/bin/perl

package Search::GIN::Core;
use Moose::Role;

use List::MoreUtils qw(uniq);

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

requires qw(
    objects_to_ids
    ids_to_objects

    extract_values
);

sub query {
    my ( $self, $query ) = @_;

    my @spec = $query->extract_values;

    my $set = $self->fetch_entries(@spec);

    my @candidate_objs = $self->ids_to_objects($set->all); # FIXME iterate

    return grep { $query->consistent($self, $_) } @candidate_objs;
}

__PACKAGE__

__END__
