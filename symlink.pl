#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use FindBin qw/$Bin/;
use File::Path qw/rmtree/;
use Pod::Usage qw/pod2usage/;
use opts;

opts
    my $force => { isa => 'Bool' },
    my $help  => { isa => 'Bool' },
;
pod2usage 1 if $help;

die '$ENV{HOME} not set' unless $ENV{HOME};

chdir $ENV{HOME};

opendir my($dh), $Bin;
for my $file (readdir $dh) {
    next if $file =~ /^\.{1,2}$|^\.git$|^[^.]/;
    if ($force && -e $file) {
        unlink $file if -f _;
        rmtree $file if -d _;
    }
    symlink "$Bin/$file", $file;
}
closedir $dh;

print "done.\n";

__END__

=head1 NAME

    symlink.pl is create(update) dotfiles symlik to $ENV{HOME}

=head1 SYNOPSIS

    symlink.pl [--force --help]

