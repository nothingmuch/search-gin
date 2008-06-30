#!/usr/bin/perl

package Search::GIN::Driver;
use Moose::Role;

use Set::Object qw(set);

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::ExpandKeys
);

requires qw(
    insert_entry
    remove_ids
    fetch_entry
);

sub fetch_entries {
    my ( $self, %args ) = @_;

    my $method = "fetch_entries_" . ( $args{method} || "any" );

    $self->$method(%args);
}

sub fetch_entries_any {
    my ( $self, %args ) = @_;

    my @values = $self->expand_keys($args{values});

    my @sets = grep { defined } map { $self->fetch_entry($_) } @values;
    return set() unless @sets;
    return $sets[0] if @sets == 1;
    return (shift @sets)->union(@sets);
}

sub fetch_entries_all {
    my ( $self, %args ) = @_;

    my @values = $self->expand_keys($args{values});

    my @sets = map { $self->fetch_entry($_) } @values;
    return set() unless @sets;
    return $sets[0] if @sets == 1;
    return (shift @sets)->intersection(@sets);
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
        my @keys = $self->expand_keys($self->extract_values($item));
        my $id = shift @ids;

        $self->insert_entry( $id, @keys );
    }
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver - 

=head1 SYNOPSIS

    use Search::GIN::Driver;

=head1 DESCRIPTION

=cut


