use strict;
use warnings;
package Search::GIN::Driver::Pack::UUID;
# ABSTRACT: UUID key packing

use Moose::Role;

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

sub unpack_ids {
    my ( $self, $str ) = @_;
    unpack("(a16)*", $str);
}

sub pack_ids {
    my ( $self, @ids ) = @_;
    pack("(a16)*", @ids); # FIXME enforce size
}

1;

__END__

=head1 SYNOPSIS

    use Search::GIN::Driver::PackUUID;

=head1 DESCRIPTION

