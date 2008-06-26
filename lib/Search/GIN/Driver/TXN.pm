#!/usr/bin/perl

package Search::GIN::Driver::TXN;
use Moose::Role;

use Carp qw(croak);

use namespace::clean -except => [qw(meta)];

with qw(Search::GIN::Driver);

requires qw(txn_begin txn_commit txn_rollback);

sub txn_do {
    my ( $self, $coderef ) = ( shift, shift );

    ref $coderef eq 'CODE' or croak '$coderef must be a CODE reference';

    return $coderef->(@_) if $self->{transaction_depth};

    my @result;
    my $want_array = wantarray;

    my $txn = $self->txn_begin;

    my $err = do {
        local $@;
        eval {
            if ( $want_array ) {
                @result = $coderef->(@_);
            } elsif( defined $want_array ) {
                $result[0] = $coderef->(@_);
            } else {
                $coderef->(@_);
            }

            $self->txn_commit($txn);

            1;
        };

        $@
    };

    if ( !$err ) {
        return $want_array ? @result : $result[0];
    } else {
        my $rollback_exception = do {
            local $@;
            eval { $self->txn_rollback($txn) };
            $@;
        };

        if ($rollback_exception) {
            croak "Transaction aborted: $err, rollback failed: $rollback_exception";
        } else {
            die $err;
        }
    }
}


__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Driver::TXN - 

=head1 SYNOPSIS

    use Search::GIN::Driver::TXN;

=head1 DESCRIPTION

=cut


