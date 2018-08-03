#!/usr/bin/perl
use strict;
use warnings;

use Term::ANSIColor;
use IPC::Open3;

my $compiler = shift @ARGV;
my @options = @ARGV;

# Keep the pid of the compiler process so we can get its return
# code and use that as our return code.
my $compiler_pid = open3('<&STDIN', \*GCCOUT, '', $compiler, @options);

my $err = color('reset').color('red');
my $warn = color('reset').color('yellow');
my $note = color('reset').color('green');
my $msg = color('reset').color('white');
my $string = color('reset').color('cyan');
my $file = color('reset').color('bold white');
my $file_ln = color('reset').color('magenta');

# Colorize the output from the compiler.
while(my $line = <GCCOUT>) {
    if(-t STDOUT) {
        $line =~ s/warning:/${warn}warning${msg}:/;
        $line =~ s/error:/${err}error${msg}:/;
        $line =~ s/undefined reference to/${err}undefined reference to${msg}:/;
        $line =~ s/note:/${note}note${msg}:/;

        if($line =~ "\e") {
            $line =~ s/'([^']*)'/'${string}$1${msg}'/g;
            $line =~ s/^([\w\/.+\-]*):(\d+)/${file}$1${msg}:${file_ln}$2${msg}/;
            $line = $msg . $line . color('reset');
        } else {
            $line = color('bold black') . $line . color('reset');
        }
    }

    print $line;
}

# Get the return code of the compiler and exit with that.
waitpid($compiler_pid, 0);
exit ($? >> 8);
