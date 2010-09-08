#!/usr/bin/perl

package Search::GIN;

use strict;
use warnings;

our $VERSION = "0.04";

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN - Generalized Inverted Indexing

=head1 DESCRIPTION

Inverted Indexing is an indexing method that maps from content to location in
storage.

Generalized Inverted Indexing (GIN, for short) is an inverted indexing method
in which the index is unaware of what data exactly is it indexing.

L<Search::GIN> is primarily used by L<KiokuDB> for custom indexing.

=head1 SEE ALSO

=over 4

=item * L<pgsql-hackers msg #00960|http://archives.postgresql.org/pgsql-hackers/
2006-04/msg00960.php>

=item * L<Inverted_index on Wikipedia|http://en.wikipedia.org/wiki/
Inverted_index>

=back

=head1 COPYRIGHT

    Copyright (c) 2008 - 2010 Yuval Kogman, Infinity Interactive. All
    rights reserved This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

=cut

