#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use opts;
use FindBin qw/$Bin/;
use File::Path qw/rmtree/;
use Pod::Usage qw/pod2usage/;
use IPC::Open3::Simple;
use Term::ANSIColor qw/colored/;

opts
    my $force => { isa => 'Bool' },
    my $help  => { isa => 'Bool' },
;
pod2usage 1 if $help;

die '$ENV{HOME} not set' unless $ENV{HOME};

my $home = $ENV{HOME}; # change safe
chdir $home;

my $ipc = IPC::Open3::Simple->new(out => sub { print "$_[0]\n" }, err => sub { warn "$_[0]\n" });

opendir my($dh), $Bin;
for my $file (readdir $dh) {
    next if $file =~ /^\.{1,2}$|^\.git$|^[^.]/;
    my $is_write = 1;
    if (-e $file) {
        if ($force) {
            unlink $file if -f _;
            rmtree $file if -d _;
        }
        else {
            print colored ['yellow bold'], "want diff ? $file [y/n] : ";
            $ipc->run('diff', '-u', "$Bin/$file", "$file") if yesno();
            print colored ['red bold'], "override ? $file [y/n] : ";
            $is_write = yesno()
        }
    }
    symlink "$Bin/$file", $file if $is_write;
}
closedir $dh;

print "done.\n";

sub yesno {
    my $answer = <>;
    chomp $answer;
    return $answer =~ /[yY]/ ? 1 : 0;
}

__END__

=head1 NAME

    symlink.pl is create(update) dotfiles symlik to $ENV{HOME}

=head1 SYNOPSIS

    symlink.pl [--force --help]

