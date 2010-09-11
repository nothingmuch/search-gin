use strict;
use warnings;
package Search::GIN::DelegateToIndexed;
# ABSTRACT:

use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Search::GIN::Core);

requires "ids_to_objects";

sub extract_values {
    my ( $self, $obj, @args ) = @_;
    $obj->gin_extract_values($self, @args);
}

sub compare_values {
    my ( $self, $obj, @args ) = @_;
    $obj->gin_compare_values($self, @args);
}

sub objects_to_ids {
    my ( $self, @objs ) = @_;
    map { $_->gin_id } @objs;
}

1;

__END__

=head1 SYNOPSIS

    use Search::GIN::DelegateToIndexed;

=head1 DESCRIPTION

