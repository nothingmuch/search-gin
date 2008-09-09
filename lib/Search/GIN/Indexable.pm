#!/usr/bin/perl

package Search::GIN::Indexable;
use Moose::Role;

requires 'gin_extract_values';

sub gin_id {
    my $self = shift;
    return $self;
}

sub gin_compare_values {
    my ( $self, $c, $one, $two ) = @_;
    $one cmp $two;
}

sub gin_consistent {
    my ( $self, $index, $c, $query, @args ) = @_;
    $query->gin_consistent($index, $c, $self, @args);
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


