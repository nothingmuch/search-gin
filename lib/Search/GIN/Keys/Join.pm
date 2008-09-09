#!/usr/bin/perl

package Search::GIN::Keys::Join;
use Moose::Role;

sub join_keys {
    my ( $self, $c, @keys ) = @_;
    map { $self->join_key($c, $_) } @keys;
}

sub join_key {
    my ( $self, $c, @key ) = @_;

    join ":", map { ref($_) ? @$_ : $_ } @key;
}

__PACKAGE__

__END__

