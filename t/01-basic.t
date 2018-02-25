#!perl

use 5.010;
use strict;
use warnings;

use Color::Theme::Util qw(create_color_theme_transform);
use Test::More 0.96;

my $ct = create_color_theme_transform(
    {colors=>{a=>'aaaa00', b=>sub {'bbbbbb'}}},
    sub { substr($_[0], 0, 4) . '33' },
);

is($ct->{colors}{a}->(), 'aaaa33', 'a');
is($ct->{colors}{b}->(), 'bbbb33', 'b');

DONE_TESTING:
done_testing;
