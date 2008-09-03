#!/usr/bin/perl

package Search::GIN::Query::Class;
use Moose;

use Carp qw(croak);

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Query
    Search::GIN::Keys::Deep
);

has no_check => (
    isa => "Bool",
    is  => "rw",
    default => 0,
);

has class => (
    isa => "ArrayRef | Str",
    is  => "ro",
    predicate => "has_class",
);

has does => (
    isa => "ArrayRef | Str",
    is  => "ro",
    predicate => "has_does",
);

has blessed => (
    isa => "Str",
    is  => "ro",
    predicate => "has_blessed",
);

sub BUILD {
    my $self = shift;

    croak "One of 'class', 'does', or 'blessed' is required"
        unless $self->has_class or $self->has_does or $self->has_blessed;
}

sub extract_values {
    my $self = shift;

    return (
        method => "all",
        values => [ $self->process_keys({
            ( $self->has_class   ? ( class   => $self->class   ) : () ),
            ( $self->has_does    ? ( does    => $self->does    ) : () ),
            ( $self->has_blessed ? ( blessed => $self->blessed ) : () ),
        }) ],
    );
}

sub consistent {
    my ( $self, $index, $object ) = @_;

    return 1 if $self->no_check;

    if ( $self->has_blessed ) {
        return unless ref($object) eq $self->blessed;
    }

    if ( $self->has_class ) {
        return unless $self->check_object($object, isa => $self->class);
    }

    if ( $self->has_does ) {
        return unless $self->check_object($object, DOES => $self->does);
    }

    return 1;
}

sub check_object {
    my ( $self, $object, $check, $classes ) = @_;

    my @classes = ref($classes) ? @$classes : $classes;

    foreach my $class ( @classes ) {
        $object->$check($class) or return;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Query::Class - 

=head1 SYNOPSIS

	use Search::GIN::Query::Class;

=head1 DESCRIPTION

=cut


