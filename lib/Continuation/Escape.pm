package Continuation::Escape;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = 'call_cc';

use Scope::Upper 'unwind';

sub _count_caller_level () {
    my $i = 0;
    1 while caller($i++);
    return $i - 1; # discard the _count_caller_level stack frame
}

sub call_cc (&) {
    my $code = shift;

    my $escape_level = _count_caller_level;

    my $escape_continuation = sub {
        my $difference = _count_caller_level - $escape_level;
        unwind @_ => $difference;
    };

    return $code->($escape_continuation);
}

1;

