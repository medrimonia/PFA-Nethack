use strict;
use warnings;

use Term::ReadKey;
use Time::HiRes qw/usleep/;
use Term::ANSIScreen qw/:cursor :screen/;



my $filename = $ARGV[0] // "replay";
open(my $fh, '<', $filename) or die "Can't open file $filename: $!";
$/ = undef; #slurp!
my $replay = <$fh>;
close $fh;


cls();
$| = 1;
$/ = "\n";

my $i = 1;
my $slideshow = 0;
my @coms = split("ES", $replay);

my @glyphs = split('g', $coms[0]);
print_glyphs(@glyphs);

while (1) {
	# Prompt
	locate 1,1; clline(); print "> ";

	if ($slideshow) {
		ReadMode('cbreak');

		for (my $t = $i; $t <= $#coms; $i++, $t++) {
			my $key = ReadKey(-1); # non-blocking read

			last if (defined $key);

			@glyphs = split('g', $coms[$t]);
			print_glyphs(@glyphs);

			usleep($slideshow);
		}

		$slideshow = 0;
	}

	else {
		ReadMode('normal');
		my $cmd = <STDIN>;

		if ($cmd =~ /^\d+$/ && $cmd <= $#coms) {
			# goto turn number in $cmd
			my $start;

			if ($i < $cmd) {
				$start = $i + 1;
			} else {
				cls();
				$start = 0;
			}

			for ($start .. $cmd) {
				@glyphs = split('g', $coms[$_]);
				print_glyphs(@glyphs);
			}

			$i = $cmd;
		}

		elsif ($cmd =~ /^s\s+(\d+)$/) {
			$slideshow = $1;
		}
	
		elsif ($i < $#coms) {
			$i++;
			@glyphs = split('g', $coms[$i]);
			print_glyphs(@glyphs);
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
