#!/usr/bin/perl

package Search::GIN::Extract::Class;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Core);

sub extract_values {
    my ( $self, $obj, @args ) = @_;

    my $class = ref $obj;

    my $meta = Class::MOP::Class->initialize($class);

    my @isa = $meta->linearized_isa;

    my @roles = $meta->can("calculate_all_roles") ? $meta->calculate_all_roles : ();

    return {
        blessed => $class,
        class   => \@isa,
        does    => \@roles,
    };
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Extract::Class - 

=head1 SYNOPSIS

	use Search::GIN::Extract::Class;

=head1 DESCRIPTION

=cut


