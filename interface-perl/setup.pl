#!/usr/bin/perl

use strict;
use warnings;

use CPAN;
use CPAN::Shell;


for my $mod (qw(IO::Pty::Easy Term::ReadKey Term::VT102)) {
	CPAN::Shell->install($mod);
}

