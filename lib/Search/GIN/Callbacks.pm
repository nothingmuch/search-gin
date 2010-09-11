use strict;
use warnings;
package Search::GIN::Callbacks;
# ABSTRACT: Provide callbacks

use Moose::Role;

with qw(Search::GIN::Core);

foreach my $cb qw(objects_to_ids extract_values extract_query compare_values consistent ids_to_objects) {
    has "${cb}_callback" => (
        isa => "CodeRef",
        is  => "rw",
        required => 1,
    );

    eval "sub $cb { \$self->${cb}_callback->(@_) }";
}

1;

__END__

=head1 DESCRIPTION

This role provides a few callbacks for L<Search::GIN>.

