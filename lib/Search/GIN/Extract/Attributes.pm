#!/usr/bin/perl

package Search::GIN::Extract::Attributes;
use Moose;

use namespace::clean -except => 'meta';

with qw(
    Search::GIN::Extract
    Search::GIN::Keys::Deep
);

has attributes => (
    isa => "ArrayRef[Str]",
    is  => "rw",
    predicate => "has_attributes",
);

sub extract_values {
    my ( $self, $obj, @args ) = @_;

    my @meta_attrs = $self->get_meta_attrs($obj, @args);

    return $self->process_keys({ map {
                                    my $val = $_->get_value($obj);
                                    $_->name => (defined($val) ? $val : undef);
                                } @meta_attrs });
}

sub get_meta_attrs {
    my ( $self, $obj, @args ) = @_;

    my $class = ref $obj;
    my $meta = Class::MOP::get_metaclass_by_name($class);

    if ( $self->has_attributes ) {
        return grep { defined } map { $meta->find_attribute_by_name($_) } @{ $self->attributes };
    } else {
        return $meta->get_all_attributes;
    }
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Extract::Attributes - 

=head1 SYNOPSIS

	use Search::GIN::Extract::Attributes;

=head1 DESCRIPTION

=cut


