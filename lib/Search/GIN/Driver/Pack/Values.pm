use strict;
use warnings;
package Search::GIN::Driver::Pack::Values;
# ABSTRACT:

use Moose::Role;

use namespace::clean -except => 'meta';

requires qw(pack_values unpack_values);

1;

__END__
