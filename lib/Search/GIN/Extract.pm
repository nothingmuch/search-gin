use strict;
use warnings;
package Search::GIN::Extract;
# ABSTRACT:

use Moose::Role;

use namespace::clean -except => 'meta';

requires 'extract_values';

1;

__END__
