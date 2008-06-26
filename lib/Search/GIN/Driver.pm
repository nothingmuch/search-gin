#!/usr/bin/perl

package Search::GIN::Driver;
use Moose::Role;

requires qw(
	txn_do
	insert_ids
	remove_ids
	fetch_entry
);

sub fetch_entries {
	my ( $self, @values ) = @_;

	my @ids = map { $self->fetch_entry($_) } @values;

	my %seen;
	return grep { !$seen{$_}++ } @ids;
}

sub remove_entries {
	my ( $self, $entries ) = @_;

	foreach my $key ( keys %$entries ) {
		$self->remove_ids($key, $entries->{$key});
	}
}

sub insert_entries {
	my ( $self, $entries ) = @_;

	foreach my $key ( keys %$entries ) {
		$self->insert_ids($key, $entries->{$key});
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


