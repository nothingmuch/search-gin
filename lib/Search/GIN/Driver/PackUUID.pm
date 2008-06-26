#!/usr/bin/perl

package Search::GIN::Driver::PackUUID;
use Moose::Role;

use Set::Object qw(set);

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

sub unpack_ids {
    my ( $self, $str ) = @_;
    set(unpack("(a16)*", $str));
}

sub pack_ids {
    my ( $self, $ids) = @_;
    pack ("(a16)*", $ids->members);
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::PackUUID - UUID key packing

=head1 SYNOPSIS

    use Search::GIN::Driver::PackUUID;

=head1 DESCRIPTION

=cut


