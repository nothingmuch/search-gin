use strict;
use warnings;
package Search::GIN::Driver::Pack::IDs;
# ABSTRACT:

use Moose::Role;

use namespace::clean -except => 'meta';

requires qw(pack_ids unpack_ids);

1;

__END__
