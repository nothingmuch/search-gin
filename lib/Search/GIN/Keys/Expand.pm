#!/usr/bin/perl

package Search::GIN::Keys::Expand;
use Moose::Role;

sub expand_keys {
    my ( $self, $c, @keys ) = @_;
    return map { $self->expand_key($c, $_) } @keys;
}

sub expand_key {
    my ( $self, $c, $value, %args ) = @_;

    return $self->expand_key_string($c, $value) if not ref $value;

    my $method = "expand_keys_" . lc ref($value);

    return $self->$method($c, $value);
}

sub expand_key_prepend {
    my ( $self, $c, $prefix, @keys ) = @_;
    return map { [ $prefix, @$_ ] } @keys;
}

sub expand_key_string {
    my ( $self, $c, $str ) = @_;
    return [ $str ];
}

sub expand_keys_array {
    my ( $self, $c, $array ) = @_;
    return map { $self->expand_key($c, $_) } @$array;
}

sub expand_keys_hash {
    my ( $self, $c, $hash ) = @_;

    return map {
        $self->expand_key_prepend(
            $c,
            $_,
            $self->expand_key($c, $hash->{$_})
        );
    } keys %$hash;
}

__PACKAGE__

__END__
