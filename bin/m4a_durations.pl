#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use autodie;

my $dir = shift || die 'Usage: m4a_dir';
opendir my $dh, $dir or die "$!: $dir";
while (my $file = readdir $dh) {
    next unless $file =~ /m4a$/;
    my $path = "$dir/$file";
    my $duration = `ffprobe -i $path -show_format -v quiet | sed -n 's/duration=//p'`;
    chomp $duration;
    my $mills = int $duration * 1000;
    say join "\t", $file, $mills;
}

# ffprobe -i HTX1-01.m4a -show_format -v quiet | sed -n 's/duration=//p'
