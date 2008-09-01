#!/usr/bin/perl

package Search::GIN::Driver::Pack::Length;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

sub pack_length {
    my ( $self, @strings ) = @_;
    pack("(n/a*)*", @strings);
}

sub unpack_length {
    my ( $self, $string ) = @_;
    unpack("(n/a*)*", $string);
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::PackLength - 

=head1 SYNOPSIS

	use Search::GIN::Driver::PackLength;

=head1 DESCRIPTION

=cut


