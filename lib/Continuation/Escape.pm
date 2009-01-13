package Continuation::Escape;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = 'call_cc';

use Scope::Upper 'unwind';

our $CURRENTEST_CONTINUATION;

sub _count_caller_level () {
    my $i = 0;
    1 while caller($i++);
    return $i - 1; # discard the _count_caller_level stack frame
}

sub call_cc (&) {
    my $code = shift;

    my $escape_level = _count_caller_level;

    my $escape_continuation = sub {
        if (!defined($CURRENTEST_CONTINUATION)) {
            require Carp;
            Carp::croak("Escape continuations are not usable outside of their original scope.");
        }

        my $difference = _count_caller_level - $escape_level;
        unwind @_ => $difference;
    };

    local $CURRENTEST_CONTINUATION = $escape_continuation;
    return $code->($escape_continuation);
}

1;

