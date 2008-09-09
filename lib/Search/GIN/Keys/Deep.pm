#!/usr/bin/perl

package Search::GIN::Keys::Deep;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(
    Search::GIN::Keys
    Search::GIN::Keys::Join
    Search::GIN::Keys::Expand
);

sub process_keys {
    my ( $self, @keys ) = @_;

    $self->join_keys( $self->expand_keys(@keys) );
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Keys::Deep - 

=head1 SYNOPSIS

	with qw(Search::GIN::Keys::Deep);

=head1 DESCRIPTION

=cut


