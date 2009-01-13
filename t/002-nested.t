#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Continuation::Escape;

my @reached;

my $ret = call_cc {
    call_cc {
        my $inner = shift;
        $inner->("from inner");
        push @reached, "inside";
    };
    push @reached, "outside";
};

is($ret, "from inner");
is_deeply([splice @reached], ["outside"]);

