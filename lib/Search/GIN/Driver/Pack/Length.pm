use strict;
use warnings;
package Search::GIN::Driver::Pack::Length;
# ABSTRACT:

use Moose::Role;

use namespace::clean -except => [qw(meta)];

sub pack_length {
    my ( $self, @strings ) = @_;
    pack("(n/a*)*", @strings);
}

sub unpack_length {
    my ( $self, $string ) = @_;
    unpack("(n/a*)*", $string);
}

1;

__END__

=head1 SYNOPSIS

	use Search::GIN::Driver::PackLength;

=head1 DESCRIPTION

