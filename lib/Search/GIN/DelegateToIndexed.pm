#!/usr/bin/perl

package Search::GIN::DelegateToIndexed;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Core);

requires "ids_to_objects";

sub extract_values {
    my ( $self, $c, $obj, @args ) = @_;
    $obj->gin_extract_values($self, $c, @args);
}

sub compare_values {
    my ( $self, $c, $obj, @args ) = @_;
    $obj->gin_compare_values($self, $c, @args);
}

sub objects_to_ids {
    my ( $self, $c, @objs ) = @_;
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


