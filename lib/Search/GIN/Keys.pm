use strict;
use warnings;
package Search::GIN::Keys;
# ABSTRACT:

use Moose::Role;
use namespace::clean -except => 'meta';

requires qw(process_keys);

1;

__END__
