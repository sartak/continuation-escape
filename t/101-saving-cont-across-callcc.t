#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Test::Exception;
use Continuation::Escape;

my $continuation;
call_cc {
    $continuation = shift;
};

TODO: {
    local $TODO = "Not bothering to check for this quite yet.";
    throws_ok {
        call_cc {
            $continuation->();
        };
    } qr/^Escape continuations are not usable outside of their original scope\./;
}

