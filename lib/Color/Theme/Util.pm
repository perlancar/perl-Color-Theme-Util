package Color::Theme::Util;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       create_color_theme_transform
                       get_color_theme
               );

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

sub get_color_theme {
    no strict 'refs';

    my $opts  = ref($_[0]) eq 'HASH' ? shift : {};
    my $name0 = shift;

    my $modprefixes    = $opts->{module_prefixes} // ["Generic::ColorTheme"];
    my $themeprefixes0 = $opts->{theme_prefixes}  // ["Default"];

    my (@themeprefixes, $name);
    if ($name0 =~ /(.+)::(.+)/) {
        @themeprefixes = ($1);
        $name = $2;
    } else {
        @themeprefixes = @$themeprefixes0;
        $name = $name0;
    }

    my @searched_mods;
    for my $modprefix (@$modprefixes) {
        for my $themeprefix (@themeprefixes) {
            my $mod = "$modprefix\::$themeprefix";
            push @searched_mods, $mod;
            (my $mod_pm = "$mod.pm") =~ s!::!/!g;
            if (eval { require $mod_pm; 1 }) {
                my $color_themes = \%{"$mod\::color_themes"};
                return $color_themes->{$name} if $color_themes->{$name};
            }
        }
    }
    die "Can't find color theme '$name0' (searched in ".
        join(", ", @searched_mods).")";
}

1;
# ABSTRACT: Utility routines related to color themes

=head1 SYNOPSIS


=head1 FUNCTIONS

=head2 create_color_theme_transform

Usage: create_color_theme_transform($basect, $func) => hash

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

=head2 get_color_theme

Usage: get_color_name([ \%opts ], $name)

Get color theme structure. Options:

=over

=item * module_prefixes => array

Default: C<< ["Generic::ColorTheme"] >>.

=item * theme_prefixes => array

Default: C<< ["Default"] >>.

=back


=head1 SEE ALSO

L<Color::Theme>

=cut
