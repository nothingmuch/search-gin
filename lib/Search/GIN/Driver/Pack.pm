use strict;
use warnings;
package Search::GIN::Driver::Pack;
# ABSTRACT:

use Moose::Role;

with qw(
    Search::GIN::Driver::Pack::Values
    Search::GIN::Driver::Pack::IDs
);

1;

__END__
