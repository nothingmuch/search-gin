#!/usr/bin/perl

package Search::GIN::Driver::Pack::Delim;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

sub pack_delim {
    my ( $self, @strings ) = @_;
    join("\0", @strings );
}

sub unpack_delim {
    my ( $self, $string ) = @_;
    split("\0", $string );
}

__PACKAGE__

__END__
