use strict;
use warnings;
package Search::GIN::Keys::Deep;
# ABSTRACT:

use Moose::Role;
use namespace::clean -except => 'meta';

with qw(
    Search::GIN::Keys
    Search::GIN::Keys::Join
    Search::GIN::Keys::Expand
);

sub process_keys {
    my ( $self, @keys ) = @_;

    $self->join_keys( $self->expand_keys(@keys) );
}

1;

__END__

=head1 SYNOPSIS

	with qw(Search::GIN::Keys::Deep);

=head1 DESCRIPTION

