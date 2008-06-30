#!/usr/bin/perl

package Search::GIN::Driver::JoinKeys;
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

=pod

=head1 NAME

Search::GIN::Driver::JoinKeys - 

=head1 SYNOPSIS

	use Search::GIN::Driver::JoinKeys;

=head1 DESCRIPTION

=cut


