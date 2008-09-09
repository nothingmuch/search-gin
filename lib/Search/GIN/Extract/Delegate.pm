#!/usr/bin/perl

package Search::GIN::Extract::Delegate;
use Moose::Role;

use namespace::clean -except => 'meta';

has extract => (
    does => "Search::GIN::Extract",
    is   => "ro",
    required => 1,
    # handles => "Search::GIN::Extract"
);

sub extract_values { shift->extract->extract_values(@_) }

__PACKAGE__

__END__
