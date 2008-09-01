#!/usr/bin/perl

package Search::GIN::Driver::Hash;
use Moose::Role;

use Set::Object qw(set);
use Scalar::Util qw(refaddr);

use namespace::clean -except => [qw(meta)];

has values => (
    isa => "HashRef",
    is  => "ro",
    default => sub { {} },
);

has objects => (
    isa => "HashRef",
    is  => "ro",
    default => sub { {} },
);

sub fetch_entry {
    my ( $self, $key ) = @_;
    $self->values->{$key};
}

sub remove_ids {
    my ( $self, @ids ) = @_;

    my $values  = $self->values;
    my $objects = $self->objects;

    my @key_sets = grep { defined } delete @{$objects}{map { refaddr($_) } @ids};
    return unless @key_sets;
    my $keys = (shift @key_sets)->union(@key_sets);

    foreach my $key ( $keys->members ) {
        my $set = $values->{$key};
        $set->remove(@ids);
        delete $values->{$key} if $set->size == 0;
    }
}

sub insert_entry {
    my ( $self, $id, @keys ) = @_;

    my $values  = $self->values;
    my $objects = $self->objects;

    $self->remove_ids($id);

    my $set = $objects->{refaddr($id)} = Set::Object->new;

    $set->insert(@keys);

    foreach my $id_set (@{$values}{@keys}) {
        $id_set ||= Set::Object->new;
        $id_set->insert($id);
    }
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::Hash - 

=head1 SYNOPSIS

    use Search::GIN::Driver::Hash;

=head1 DESCRIPTION

=cut


