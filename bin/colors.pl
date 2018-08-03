#!/usr/bin/perl
use strict; use warnings;
use Getopt::Std;    # cli options

# read command line options
my %options;
getopts('hlb:', \%options);

if($options{h}) {
print '
        -h          Show help info.
        -l          Show all FG/BG color combos and bold versions.
        -b <color>  Set BG color to <color>. Add 10 to any FG color to get the equivalent BG color.

';
exit;
}

if($options{l}) {
    print "Background | Foreground colors\n";
    print "---------------------------------------------------------------------\n";
    for(my $bg = 40; $bg <= 47; $bg++) {
            for(my $bold = 0; $bold <= 1; $bold++) {
                    print "\e[0m ESC[${bg}m   | ";
                    for(my $fg = 30; $fg <= 37; $fg++) {
                            if($bold eq '0') {
                                    print "\e[${bg}m\e[${fg}m [${fg}m  ";
                            } else {
                                    print "\e[${bg}m\e[1;${fg}m [1;${fg}m";
                            }
                    }
                    print "\e[0m\n";
            }
    }
} else {
    print "\e[$options{b}m" if $options{b};
    foreach my $color(qw(31 32 33 34 35 36 30 90 37 39)) {
        print "  \e[${color}mESC[${color}m";
    }
    print "\e[0m\n";
}
