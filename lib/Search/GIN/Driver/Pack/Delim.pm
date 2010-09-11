use strict;
use warnings;
package Search::GIN::Driver::Pack::Delim;
# ABSTRACT:

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

1;

__END__
