#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use FindBin qw/$Bin/;
use File::Path qw/rmtree/;
use File::Basename qw/basename/;
use Getopt::Long qw/GetOptions/;
use Pod::Usage qw/pod2usage/;
use IPC::Open3::Simple;
use Term::ANSIColor qw/colored/;

GetOptions(
    'f|force!' => \my $force,
    'h|help!'  => \my $help,
) or pod2usage 1;
pod2usage 1 if $help;

die '$ENV{HOME} not set' unless $ENV{HOME};

my $home = $ENV{HOME}; # change safe
chdir $home;

my $ipc = IPC::Open3::Simple->new(out => sub { print "$_[0]\n" }, err => sub { warn "$_[0]\n" });

opendir my($dh), $Bin;
for my $file (readdir $dh) {
    next if $file =~ /^\.{1,2}$|^\.git$/;
    next if $file eq basename $0;
    my $is_write = 1;
    if (-e $file) {
        next if -l $file;
        unless ($force) {
            print colored ['yellow bold'], "want diff ? $file [y/n] : ";
            $ipc->run('diff', '-u', "$home/$file", "$Bin/$file") if yes();
            print colored ['red bold'], "override ? $file [y/n] : ";
            $is_write = yes()
        }
    }
    if ($is_write) {
        unlink $file if -f _;
        rmtree $file if -d _;
        symlink "$Bin/$file", $file;
        chmod 0600, $file if ($file eq '.pause');
    }
}
closedir $dh;

print "done.\n";

sub yes {
    my $answer = <>;
    chomp $answer;
    return $answer =~ /[yY]/ ? 1 : 0;
}

__END__

=head1 NAME

    symlink.pl is create(update) dotfiles symlik to $ENV{HOME}

=head1 SYNOPSIS

    symlink.pl [--force --help]

