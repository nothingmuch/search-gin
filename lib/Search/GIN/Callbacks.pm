#!/usr/bin/perl

package Search::GIN::Callbacks;
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

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Callbacks - 

=head1 SYNOPSIS

    use Search::GIN::Callbacks;

=head1 DESCRIPTION

=cut


