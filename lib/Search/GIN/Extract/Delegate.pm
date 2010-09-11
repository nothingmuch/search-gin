use strict;
use warnings;
package Search::GIN::Extract::Delegate;
# ABSTRACT:

use Moose::Role;
use namespace::clean -except => 'meta';

has extract => (
    does => "Search::GIN::Extract",
    is   => "ro",
    required => 1,
    # handles => "Search::GIN::Extract"
);

sub extract_values { shift->extract->extract_values(@_) }

1;

__END__
