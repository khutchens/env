#!/usr/bin/perl
use strict;
use warnings;

use Term::ANSIColor;
use Getopt::Std;    # cli options

# Read command line options.
my %options;
getopts('hc:', \%options);

# Help output.
if($options{h}) {
print '
usage: log_color [-h] [-c <filename>]

This script takes input from STDIN and adds formatting for easier reading. It\'s intended to be used together with
`tail -f` or other log sources to colorize log files.

Example:
    tail -f -n 0 example.log | log_color -c colors.txt

Options:
    -h          Show help info.
    -c          Specify config file which should include a list of /regex/ \'color\' values, one per line.
                    Defaults to \'~/.log_color\' if not specified.

';
exit;
}

# Use default config file if one wasn't specified.
my $fname_cfg;
if(defined $options{c}) {
    $fname_cfg = $options{c};
} else {
    $fname_cfg = '~/.log_color';
}

# Read config file.
my %colors;
my $lnum = 1;
print "Loading config file '$fname_cfg'...\n";
open(F_CFG, "<$fname_cfg") || die "Failed opening config file '$fname_cfg'";
while(my $line = <F_CFG>) {
    chomp $line;

    # Strip comments.
    $line =~ s/#.*//;

    # Skip blank lines
    if($line =~ /^$/) {
        next;
    }

    # Check for /regex/ 'color' pair.
    my($regex, $color) = $line =~ /\s*\/([^\/]+)\/\s*'([\w ]+)'\s*/;
    if(defined $color) {
        my $color_code;
        eval {
            $color_code = color($color);
        };
        if($@) {
            warn "Invalid color code at $fname_cfg:$lnum: '$color'\n";
        } else {
            print "    $regex -> $color\n";
            $colors{$regex} = $color_code;
        }
    }
    $lnum++;
}

# Start processing log from STDIN.
my $color = color('white');
my $reset = color('reset');
while(my $line = <STDIN>) {
    foreach my $tag (keys %colors) {
        if($line =~ /^$tag/) {
            $color = $colors{$tag};
            last;
        } else {
            $color = color('white');
        }
    }
    print "${color}${line}${reset}";
}

