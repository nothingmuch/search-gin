#!/usr/bin/perl

package Search::GIN::Driver::Hash;
use Moose::Role;

use Set::Object qw(set);

use namespace::clean -except => [qw(meta)];

with qw(
	Search::GIN::Driver::TXN
);

has hash => (
	isa => "HashRef",
	is  => "ro",
	default => sub { {} },
);

sub txn_begin { }

sub txn_commit { }

sub txn_rollback { }

sub fetch_entry {
	my ( $self, $key ) = @_;
	( $self->hash->{$key} || return )->members;
}

sub remove_ids {
	my ( $self, $key, $ids ) = @_;

	if ( my $set = $self->hash-{$key} ) {
		$set->remove(@$ids);
		delete $self->hash->{$key} if $set->size == 0; 
	}
}

sub insert_ids {
	my ( $self, $key, $ids ) = @_;

	my $set = $self->hash->{$key} ||= Set::Object->new;
	$set->insert(@$ids);
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


