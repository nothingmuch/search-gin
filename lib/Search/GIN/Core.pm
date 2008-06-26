#!/usr/bin/perl

package Search::GIN::Core;
use Moose::Role;

use List::MoreUtils qw(uniq);

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

requires qw(objects_to_ids extract_values extract_query compare_values consistent ids_to_objects);

sub query {
    my ( $self, $query ) = @_;

    my @values = $self->extract_query($query);

    my @candidate_ids = $self->fetch_entries(@values);

    my @candidate_objs = $self->ids_to_objects(@candidate_ids);

    return grep { $self->consistent($_, $query, @values) } @candidate_objs;
}

sub insert {
    my ( $self, @items ) = @_;

    my $entries = $self->extract_entries(@items);

    $self->txn_do(sub {
        $self->insert_entries($entries);
    });
}

sub remove {
    my ( $self, @items ) = @_;

    my $entries = $self->extract_entries(@items);

    $self->txn_do(sub {
        $self->remove_entries($entries);
    });
}

sub extract_entries {
    my ( $self, @items ) = @_;

    my %entries;

    my @ids = $self->objects_to_ids(@items);
    foreach my $item ( @items ) {
        my @keys = $self->extract_values($item);
        my $id = shift @ids;

        foreach my $key ( @keys ) {
            push @{ $entries{$key} ||= [] }, $id;
        }
    }

    return \%entries;
}

__PACKAGE__

__END__
