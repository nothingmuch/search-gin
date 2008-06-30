#!/usr/bin/perl

package Search::GIN::DelegateToIndexed;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Core);

requires "ids_to_objects";

BEGIN {
    foreach my $method qw(extract_values compare_values) {
        eval "sub $method {
            my ( \$self, \$obj, \@args ) = \@_;
            \$obj->gin_$method(\$self, \@args);
        }";
    }
}

sub objects_to_ids {
    my ( $self, @objs ) = @_;
    map { $_->gin_id } @objs;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::DelegateToIndexed - 

=head1 SYNOPSIS

    use Search::GIN::DelegateToIndexed;

=head1 DESCRIPTION

=cut


