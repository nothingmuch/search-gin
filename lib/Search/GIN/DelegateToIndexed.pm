#!/usr/bin/perl

package Search::GIN::DelegateToIndexed;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Search::GIN::Core);

requires "ids_to_objects";

sub extract_values {
    my ( $self, $obj, @args ) = @_;
    $obj->gin_extract_values($self, @args);
}

sub compare_values {
    my ( $self, $obj, @args ) = @_;
    $obj->gin_compare_values($self, @args);
}

sub objects_to_ids {
    my ( $self, @objs ) = @_;
    map { $_->gin_id } @objs;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::DelegateToIndexed - 

=head1 SYNOPSIS

    use Search::GIN::DelegateToIndexed;

=head1 DESCRIPTION

=cut


