#!/usr/bin/perl

use strict;
use warnings;

use CPAN;
use CPAN::Shell;


for my $mod (qw(Term::ReadKey Term::ANSIScreen)) {
	CPAN::Shell->install($mod);
}

