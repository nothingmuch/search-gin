use strict;
use warnings;
package Search::GIN::Query;
# ABSTRACT:

use Moose::Role;
use namespace::clean -except => [qw(meta)];

requires qw(
    consistent
    extract_values
);

1;

__END__

=head1 SYNOPSIS

    use Search::GIN::Query;

=head1 DESCRIPTION

