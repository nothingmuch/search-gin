#!/usr/bin/perl

package Search::GIN::Keys::Join;
use Moose::Role;

sub join_keys {
    my ( $self, @keys ) = @_;
    map { $self->join_key($_) } @keys;
}

sub join_key {
    my ( $self, @key ) = @_;

    join ":", map { ref($_) ? @$_ : $_ } @key;
}

__PACKAGE__

__END__

