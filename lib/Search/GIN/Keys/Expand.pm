#!/usr/bin/perl

package Search::GIN::Keys::Expand;
use Moose::Role;

use Carp qw(croak);

use namespace::clean -except => 'meta';

sub expand_keys {
    my ( $self, @keys ) = @_;
    return map { $self->expand_key($_) } @keys;
}

sub expand_key {
    my ( $self, $value, %args ) = @_;

    return $self->expand_key_string($value) if not ref $value;

    my $method = "expand_keys_" . lc ref($value);

    croak("Don't know how to expand $value in key") if $method =~ /::/ or not $self->can($method);

    return $self->$method($value);
}

sub expand_key_prepend {
    my ( $self, $prefix, @keys ) = @_;
    return map { [ $prefix, @$_ ] } @keys;
}

sub expand_key_string {
    my ( $self, $str ) = @_;
    return [ $str ];
}

sub expand_keys_array {
    my ( $self, $array ) = @_;
    return map { $self->expand_key($_) } @$array;
}

sub expand_keys_hash {
    my ( $self, $hash ) = @_;

    return map {
        $self->expand_key_prepend(
            $_,
            $self->expand_key($hash->{$_})
        );
    } keys %$hash;
}

__PACKAGE__

__END__
