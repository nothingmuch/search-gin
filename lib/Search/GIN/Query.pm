#!/usr/bin/perl

package Search::GIN::Query;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

requires qw(
    consistent
    extract_values
);

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Query - 

=head1 SYNOPSIS

    use Search::GIN::Query;

=head1 DESCRIPTION

=cut


