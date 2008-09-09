#!/usr/bin/perl

package Search::GIN::Driver;
use Moose::Role;

use Data::Stream::Bulk::Util qw(bulk nil cat unique);

use namespace::clean -except => [qw(meta)];

requires qw(
    insert_entry
    remove_ids
    fetch_entry
);

sub fetch_entry_streams {
    my ( $self, %args ) = @_;
    map { $self->fetch_entry($_) } @{ $args{values} };
}

sub fetch_entries {
    my ( $self, %args ) = @_;

    my $method = "fetch_entries_" . ( $args{method} || "any" );

    $self->$method(%args);
}

sub fetch_entries_any {
    my ( $self, @args ) = @_;

    my @streams = $self->fetch_entry_streams(@args);

    return nil unless @streams;

    my $res = cat(splice @streams); # splice disposes of @streams ASAP, keeping memory utilization down

    if ( $res->loaded ) {
        # if all results are already ready, we can uniqify them to avoid
        # duplicate calls to ->consistent
        return unique($res);
    } else {
        return $res;
    }
}

sub fetch_entries_all {
    my ( $self, @args ) = @_;

    my @streams = $self->fetch_entry_streams(@args);

    return nil unless @streams;
    return $streams[0] if @streams == 1;

    foreach my $stream ( @streams ) {
        return cat(splice @streams) unless $stream->loaded;
    }

    # if we made it to here then we have a > 1 list of fully realized streams
    # we can compute the intersection of the IDs to avoid unnecessary calls to
    # ->consistent

    # If all streams are known to be sorted this method could be overridden to
    # use merge sorting

    my $last = shift @streams;
    my $n = scalar @streams;

    # compute intersection
    my %seen;
    foreach my $stream ( splice @streams ) {
        ++$seen{$_} for $stream->all;
    }

    no warnings 'uninitialized'; # == with undef
    return bulk( grep { $seen{$_} == $n } $last->all );
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver - 

=head1 SYNOPSIS

    use Search::GIN::Driver;

=head1 DESCRIPTION

=cut


