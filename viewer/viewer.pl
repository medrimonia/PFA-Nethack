use v5.10;
use strict;
use warnings;

use Term::ReadKey;
use Time::HiRes qw/sleep/;
use Term::ANSIScreen qw/:cursor :screen/;


if ($#ARGV < 0) {
	print "Usage: perl $0 <replay file>\n";
	exit;
}


my @coms;
my @coms_reversed;

{	# slurp @coms from $filename

	local $/ = undef;

	my $filename = $ARGV[0];
	open(my $fh, '<', $filename)
		or die "Can't open file $filename: $!";
	my $replay = <$fh>;
	close $fh;

	@coms = split("ES", $replay);
}

{	# build @coms_reversed

	my $tmpmap = [[]]; # remember what was where

	for (@coms) {
		my @glyphs_reversed;
		my @glyphs = split 'g';

		for (@glyphs) {
			my ($y, $x, $g) = unpack("WWa");

			if (defined $g) {
				# use 'unshift' to reverse the order of appearance of glyphs
				# and don't forget to pack the leading 'g' code
				unshift
					@glyphs_reversed,
					pack("aWWa", 'g', $y, $x, $tmpmap->[$x]->[$y] // " ");
				$tmpmap->[$x]->[$y] = $g;
			}
		}

		# make sure each element of @coms_reversed is a string (same as
		# @coms)
		push @coms_reversed, "@glyphs_reversed";
	}
}


cls();
$| = 1;

my $turn = 0;
my $slideshow = 0;
my $slideshow_reversed = 0;

# print first set of glyphs (initial map)
my @glyphs = split('g', $coms[0]);
print_glyphs(@glyphs);

ReadMode('cbreak');

while (1) {
	locate 1,1; clline(); print "turn $turn";

	if ($slideshow) {

		if ($turn <= $#coms) {
			sleep(1./$slideshow);

			$turn++;
			@glyphs = split('g', $coms[$turn]);
			print_glyphs(@glyphs);

			$slideshow = 0 if (defined ReadKey(-1));
		}
		
		else {
			$slideshow = 0;
		}
	}

	elsif ($slideshow_reversed) {
		if ($turn > 0) {
			sleep(1./$slideshow_reversed);

			$turn--;
			@glyphs = split('g', $coms_reversed[$turn+1]);
			print_glyphs(@glyphs);

			$slideshow_reversed = 0 if (defined ReadKey(-1));
		}
		
		else {
			$slideshow_reversed = 0;
		}
	}

	else {
		my $key = ReadKey(0);
		$slideshow = 0;

		if ($key eq 'j' && $turn < $#coms) {
			$turn++;
			@glyphs = split('g', $coms[$turn]);
			print_glyphs(@glyphs);
		}

		elsif ($key eq 'k' && $turn > 0) {
			$turn--;
			@glyphs = split('g', $coms_reversed[$turn+1]);
			print_glyphs(@glyphs);
		}

		elsif ($key eq ':') {
			my $cmd;

			# prompt
			locate 1,1; clline(); print "turn $turn : ";
			ReadMode('normal');
			
			unless (defined ($cmd = <STDIN>)) {
				cls();
				exit;
			}

			ReadMode('cbreak');
			chomp $cmd;

			if ($cmd =~ /^\d+$/ && $cmd <= $#coms) {
				# goto turn number in $cmd
				my $step;
				my $coms_array;

				if ($turn <= $cmd) {
					$step = 1;
					$coms_array = \@coms;
				} else {
					$step = -1;
					$coms_array = \@coms_reversed;
				}

				for (; $turn != $cmd; $turn += $step) {
					# replay until $turn == $cmd
					@glyphs = split('g', $coms_array->[$turn]);
					print_glyphs(@glyphs);
				}
			}

			elsif ($cmd =~ /^s\s*(\d+)$/) {
				$slideshow = $1;
			}
			
			elsif ($cmd =~ /^b\s*(\d+)$/) {
				$slideshow_reversed = $1;
			}
		}
	}
}


sub print_glyphs {
	local $| = 0;

	for (@_) {
		my ($y, $x, $g) = unpack("WWa");

		if (defined $g) {
			locate $x+2, $y+1;
			print $g;
		}
	}
}
