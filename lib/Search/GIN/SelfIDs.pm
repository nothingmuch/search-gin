#!/usr/bin/perl

package Search::GIN::SelfIDs;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

sub ids_to_objects {
    my ( $self, @ids ) = @_;
    return @ids;
}

sub objects_to_ids {
    my ( $self, @objs ) = @_;
    return @objs;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::SelfIDs - 

=head1 SYNOPSIS

	use Search::GIN::SelfIDs;

=head1 DESCRIPTION

=cut


