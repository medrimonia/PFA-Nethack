use v5.10;
use strict;
use warnings;

use Data::Dumper;
use Term::ReadKey;
use Time::HiRes qw/sleep/;
use Term::ANSIScreen qw/:cursor :screen/;


if ($#ARGV < 0) {
	print "Usage: perl $0 <replay file>\n";
	exit;
}


my @buf;
my @coms;
my @coms_reversed;

{	# slurp @buf from $filename

	local $/ = undef;

	my $filename = $ARGV[0];
	open(my $fh, '<', $filename)
		or die "Can't open file $filename: $!";
	my $replay = <$fh>;
	close $fh;

	@buf = split("ES", $replay);
}

{	# build @coms and @coms_reversed

	for my $i (0 .. $#buf) {
		my @glyphs;
		my @tmp = split('', $buf[$i]);

		for (my $j = 0; $j <= $#tmp; $j++) {

			if (($tmp[$j] eq 'g') && ($j + 5 <= $#tmp)) {
				push @glyphs, join('', @tmp[$j+1 .. $j+3]);
				$j += 5;
			}
		}

		$coms[$i] = \@glyphs;
	}

	my $tmpmap = [[]]; # remember what was where

	for my $i (0 .. $#coms) {
		my @glyphs;

		for (@{$coms[$i]}) {
			my ($y, $x, $g) = unpack("CCa");

			if (defined $g) {
				# use 'unshift' to reverse the order of appearance of glyphs
				unshift
					@glyphs,
					pack("WWa", $y, $x, $tmpmap->[$x]->[$y] // " ");
				$tmpmap->[$x]->[$y] = $g;
			}
		}

		$coms_reversed[$i] = \@glyphs;
	}
}


cls();
$| = 1;

my $turn = 0;
my $slideshow = 0;
my $slideshow_reversed = 0;

# print first set of glyphs (initial map)
print_glyphs($coms[0]);

ReadMode('cbreak');

while (1) {
	locate 1,1; clline(); print "turn $turn";

	if ($slideshow) {

		if ($turn < $#coms) {
			sleep(1./$slideshow);

			$turn++;
			print_glyphs($coms[$turn]);

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
			print_glyphs($coms_reversed[$turn+1]);

			$slideshow_reversed = 0 if (defined ReadKey(-1));
		}
		
		else {
			$slideshow_reversed = 0;
		}
	}

	else {
		my $key = ReadKey(0);

		if ($key eq 'j' && $turn < $#coms) {
			$turn++;
			print_glyphs($coms[$turn]);
		}

		elsif ($key eq 'k' && $turn > 0) {
			$turn--;
			print_glyphs($coms_reversed[$turn+1]);
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
					print_glyphs($coms_array->[$turn]);
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
	my ($ref) = @_;

	for (@{$ref}) {
		my ($y, $x, $g) = unpack("WWa");

		if (defined $g) {
			locate $x+2, $y+1;
			print $g;
		}
	}
}
