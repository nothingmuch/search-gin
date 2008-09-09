#!/usr/bin/perl

package Search::GIN::SelfIDs;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

sub ids_to_objects {
    my ( $self, $c, @ids ) = @_;
    return @ids;
}

sub objects_to_ids {
    my ( $self, $c, @objs ) = @_;
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


