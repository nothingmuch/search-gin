#!/usr/bin/perl

package Search::GIN::Query::Manual;
use Moose;

use namespace::clean -except => 'meta';

with qw(
    Search::GIN::Query
    Search::GIN::Keys::Deep
);

has method => (
    isa => "Str",
    is  => "ro",
    predicate => "has_method",
);

has values => (
    isa => "Any",
    is  => "ro",
    required => 1,
);

has _processed => (
    is => "ro",
    lazy_build => 1,
);

has filter => (
    isa => "CodeRef|Str",
    is  => "ro",
);

sub _build__processed {
    my $self = shift;
    return [ $self->process_keys( $self->values ) ];
}

sub extract_values {
    my $self = shift;

    return (
        values => $self->_processed,
        $self->has_method ? ( method => $self->method ) : (),
    );
}

sub consistent {
    my ( $self, $obj ) = @_;

    if ( my $filter = $self->filter ) {
        return $obj->$filter;
    } else {
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Query::Manual - 

=head1 SYNOPSIS

	use Search::GIN::Query::Manual;

=head1 DESCRIPTION

=cut


