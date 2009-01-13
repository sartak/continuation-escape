package Continuation::Escape;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = 'call_cc';

use Scope::Upper 'unwind';
use Scalar::Util 'refaddr';

# This registry is just so we can make sure that the user is NOT trying to save
# and run continuations later. There's no way in hell Perl 5 can support real
# unlimited continuations without a biblical amount of rototilling.
# Sorry if the name got you excited. :/
our %CONTINUATION_REGISTRY;

sub _count_caller_level () {
    my $i = 0;
    1 while caller($i++);
    return $i - 1; # discard the _count_caller_level stack frame
}

sub call_cc (&) {
    my $code = shift;

    my $escape_level = _count_caller_level;

    my $escape_continuation;
    $escape_continuation = sub {
        if (!exists($CONTINUATION_REGISTRY{refaddr $escape_continuation})) {
            require Carp;
            Carp::croak("Escape continuations are not usable outside of their original scope.");
        }

        my $difference = _count_caller_level - $escape_level;
        unwind @_ => $difference;
    };

    local $CONTINUATION_REGISTRY{refaddr $escape_continuation} = $escape_continuation;
    return $code->($escape_continuation);
}

1;

