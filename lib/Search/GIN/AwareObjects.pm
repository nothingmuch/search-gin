#!/usr/bin/perl

package Search::GIN::AwareObjects;
use Moose::Role;

with qw(Search::GIN::Core);

requires "ids_to_objects";

BEGIN {
	foreach my $method qw(extract_values compare_values consistent) {
		eval "sub $method {
			my ( \$self, \$obj, \@args ) = \@_;
			\$obj->gin_$method(\@args);
		}";
	}
}

sub extract_query {
	my ( $self, $query, @args ) = @_;
	$query->gin_extract_values($query, @args);
}

sub objects_to_ids {
	my ( $self, @objs ) = @_;
	map { $_->gin_id } @objs;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::AwareObjects - 

=head1 SYNOPSIS

	use Search::GIN::AwareObjects;

=head1 DESCRIPTION

=cut


