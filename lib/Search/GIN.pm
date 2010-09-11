use strict;
use warnings;
package Search::GIN;
# ABSTRACT: Generalized Inverted Indexing

1;

__END__

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

