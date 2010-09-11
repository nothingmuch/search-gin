use strict;
use warnings;
package Search::GIN::Extract::Callback;
# ABSTRACT:

use Moose;
use namespace::clean -except => 'meta';

with qw(
    Search::GIN::Extract
    Search::GIN::Keys::Deep
);

has extract => (
    isa => "CodeRef|Str",
    is  => "ro",
    required => 1,
);

sub extract_values {
    my ( $self, $obj, @args ) = @_;

    my $extract = $self->extract;

    $self->process_keys( $obj->$extract($self, @args) );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

	use Search::GIN::Extract::Callback;

=head1 DESCRIPTION

