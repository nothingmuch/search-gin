#!/usr/bin/perl

package Search::GIN::Driver::Pack::Delim;
use Moose::Role;

use Set::Object qw(set);

use namespace::clean -except => [qw(meta)];

sub pack_delim {
    my ( $self, $strings ) = @_;
    join("\0", $strings->members );
}

sub unpack_delim {
    my ( $self, $string ) = @_;
    set(split("\0", $string ));
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::PackDelim - 

=head1 SYNOPSIS

	use Search::GIN::Driver::PackDelim;

=head1 DESCRIPTION

=cut


