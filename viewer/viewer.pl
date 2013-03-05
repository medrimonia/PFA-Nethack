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


my @coms;
my @coms_reversed;

my $replay;

{	# slurp from $filename

	local $/ = undef;

	my $filename = $ARGV[0];
	open(my $fh, '<', $filename)
		or die "Can't open file $filename: $!";
	my $replay = <$fh>;
	close $fh;

	# build @coms and @coms_reversed

	my @glyphs;
	my @glyphs_r;
	my @tmp = split('', $replay);

	my $tmpmap = [[]]; # remember what was where

	for (my $j = 0, my $i = 0; $j <= $#tmp; $j++) {

		if (($tmp[$j] eq 'g') && ($j + 5 <= $#tmp)) {
			my $glyph = join('', @tmp[$j+1 .. $j+5]);
			my ($y, $x, $g, $code) = unpack("CCaS", $glyph);

			push
				@glyphs,
				pack("CCa", $y, $x, $g);

			unshift 
				@glyphs_r,
				pack("CCa", $y, $x, $tmpmap->[$x]->[$y] // " ");

			$j += 5;
			$tmpmap->[$x]->[$y] = $g;
		}

		elsif ($tmp[$j] eq 'E') {
			my @glyphs_copy   = @glyphs;
			my @glyphs_r_copy = @glyphs_r;

			$coms[$i]          = \@glyphs_copy;
			$coms_reversed[$i] = \@glyphs_r_copy;

			@glyphs   = ();
			@glyphs_r = ();

			$i++;
		}
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
				if ($turn <= $cmd) {
					while ($turn != $cmd) {
						$turn++;
						print_glyphs($coms[$turn]);
					}
				} else {
					while ($turn != $cmd) {
						$turn--;
						print_glyphs($coms_reversed[$turn+1]);
					}
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
