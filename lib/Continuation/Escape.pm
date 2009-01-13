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

sub call_cc (&) {
    my $code = shift;

    my $caller_level = do {
        my $i = 0;
        1 while caller($i++);
        $i;
    };

    my $escape_continuation = sub {
        unwind @_ => $caller_level;
    };

    return $code->($escape_continuation);
}

1;

