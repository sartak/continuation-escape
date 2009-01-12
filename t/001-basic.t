#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Continuation::Escape;

my $result = call_cc {
    my $escape = shift;

    sub { $escape->("yatta") }->();

    fail("This should never be reached");
};

is($result, "yatta");
