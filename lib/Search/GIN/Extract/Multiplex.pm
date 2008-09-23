#!/usr/bin/perl

package Search::GIN::Extract::Multiplex;
use Moose;

use namespace::clean -except => 'meta';

with qw(Search::GIN::Extract);

has extractors => (
    isa => "ArrayRef[Search::GIN::Extract]",
    is  => "ro",
    required => 1,
);

sub extract_values {
    my ( $self, @args ) = @_;

    return map { $_->extract_values } @{ $self->extractors };
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Extract::Multiplex - 

=head1 SYNOPSIS

	use Search::GIN::Extract::Multiplex;

=head1 DESCRIPTION

=cut


