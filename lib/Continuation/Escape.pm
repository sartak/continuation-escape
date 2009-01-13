package Continuation::Escape;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = 'call_cc';

use Scope::Upper 'unwind';

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

