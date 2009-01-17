package Continuation::Escape;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = 'call_cc';

use Scope::Upper qw/unwind HERE/;

# This registry is just so we can make sure that the user is NOT trying to save
# and run continuations later. There's no way in hell Perl 5 can support real
# unlimited continuations without a biblical amount of rototilling.
# Sorry if the name got you excited. :/
our %CONTINUATION_REGISTRY;

sub call_cc (&) {
    my $code = shift;

    my $escape_level = HERE;

    my $escape_continuation;
    $escape_continuation = sub {
        if (!exists($CONTINUATION_REGISTRY{$escape_continuation})) {
            require Carp;
            Carp::croak("Escape continuations are not usable outside of their original scope.");
        }

        unwind @_ => $escape_level;
    };

    local $CONTINUATION_REGISTRY{$escape_continuation} = $escape_continuation;
    return $code->($escape_continuation);
}

1;

__END__

=head1 NAME

Continuation::Escape - escape continuations (returning higher up the stack)

=head1 SYNOPSIS

    use Continuation::Escape;

    my $ret = call_cc {
        my $escape = shift;

        # ...
        sub {
            # ...
            $escape->(1 + 1);
            # code never reached
        }->();
        # code never reached
    };

    $ret # 2

=head1 NAME

An escape continuation is a limited type of continuation that only allows you
to jump back up the stack. Invoking an escape continuation is a lot like
throwing an exception, however escape continuations do not necessarily indicate
exceptional circumstances.

B<The interface for context will probably change.> Right now when squeezing a
list into scalar context, the B<last> element is used, instead of the usual
squeezing into the number of elements in that list. In the meantime, just use
the same context on the receiving end as the sending end.

This module builds on Vincent Pit's excellent L<Scope::Upper> to give you a
nicer interface to returning to outer scopes.

=head1 CAVEATS

Escape continuations are B<not> real continuations. They are not re-invokable
(meaning you only get to run them once) and they are not savable (once the
C<call_cc> block ends, calling the continuation it gave you is an error). This
module goes to some length to ensure that you do not try to do either of these
things.

Real continuations in Perl would require a lot of work. But damn would they be
nice. Does anyone know how much work would even be involved? C<:)>

=head1 AUTHOR

Shawn M Moore, C<sartak@bestpractical.com>

=head1 THANKS TO

Vincent Pit for writing the excellent L<Scope::Upper> which does B<two> things
that I've wanted forever (escape continuations and localizing variables at
higher stack levels).

=cut

