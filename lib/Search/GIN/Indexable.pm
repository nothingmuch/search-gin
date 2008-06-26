#!/usr/bin/perl

package Search::GIN::Indexable;
use Moose::Role;

requires qw(
	gin_id
	gin_extract_values
	gin_compare_values
);

sub gin_consistent {
	my ( $self, $query, @args ) = @_;
	$query->gin_consistent($self, @args);
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Indexable - 

=head1 SYNOPSIS

	use Search::GIN::Indexable;

=head1 DESCRIPTION

=cut


