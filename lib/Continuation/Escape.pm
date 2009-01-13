package Continuation::Escape;
use strict;
use warnings;
use Scope::Upper 'unwind';
use Sub::Exporter -setup => {
    exports => ['call_cc'],
    groups => {
        default => ['call_cc'],
    },
};

sub _count_caller_level {
    my $i = 0;
    1 while caller($i++);
    return $i - 1; # -1 to discard _count_caller_level's stack frame
}

sub call_cc (&) {
    my $code = shift;

    my $caller_level = _count_caller_level;

    my $escape_continuation = sub {
        unwind @_ => $caller_level;
    };

    return $code->($escape_continuation);
}

1;

