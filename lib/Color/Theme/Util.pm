package Color::Theme::Util;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(create_color_theme_transform);

sub create_color_theme_transform {
    my ($basect, $func) = @_;

    my $derivedct = {};

    for my $cn (keys %{ $basect->{colors} }) {
        my $cv = $basect->{colors}{$cn};

        if ($cv) {
            $derivedct->{colors}{$cn} = sub {
                my ($self, %args) = @_;
                my $basec = $basect->{colors}{$cn};
                if (ref($basec) eq 'CODE') {
                    $basec = $basec->($self, name=>$cn, %args);
                }
                if ($basec) {
                    if (ref($basec) eq 'ARRAY') {
                        $basec = [map {defined($_) && /^#?[0-9A-Fa-f]{6}$/ ?
                                           $func->($_) : $_} @$basec];
                    } else {
                        for ($basec) {
                            $_ = defined($_) && /^#?[0-9A-Fa-f]{6}$/ ?
                                $func->($_) : $_;
                        }
                    }
                }
                return $basec;
            };
        } else {
            #$derivedct->{colors}{$cn} = $cv;
        }
    }
    $derivedct;
}

1;
# ABSTRACT: Utility routines related to color themes

=head1 FUNCTIONS

=head2 create_color_theme_transform($basect, $func) => HASH

Create a new color theme by applying transform function C<$func> (code) to base
theme C<$basetheme> (hash). For example if you want to create a reddish
L<Text::ANSITable> color theme from the default theme:

 use Color::RGB::Util qw(mix_2_rgb_colors);
 use Color::Theme::Util qw(create_color_theme_transform);
 use Text::ANSITable;

 my $basetheme = Text::ANSITable->get_color_theme("Default::default_gradation");
 my $redtheme  = create_color_theme_transform(
     $basetheme, sub { mix_2_rgb_colors(shift, 'ff0000') });

 # use the color theme
 my $t = Text::ANSITable->new;
 $t->color_theme($redtheme);


=head1 SEE ALSO

L<Color::Theme>

=cut
