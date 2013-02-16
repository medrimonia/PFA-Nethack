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

my $slideshow = 0;
my @coms = split("ES", $replay);

my @glyphs = split('g', $coms[0]);
print_glyphs(@glyphs);
my $turn = 0;

while (1) {

	if ($slideshow) {
		ReadMode('cbreak');

		for (my $t = $turn; $t <= $#coms; $turn++, $t++) {
			@glyphs = split('g', $coms[$t]);
			print_glyphs(@glyphs);

			# Prompt
			locate 1,1; clline(); print "turn $t > ";

			usleep($slideshow);

			my $key = ReadKey(-1); # non-blocking read
			last if (defined $key);

		}

		$slideshow = 0;
	}

	else {
		my $cmd;
		ReadMode('normal');

		# Prompt
		locate 1,1; clline(); print "turn $turn > ";
		unless (defined ($cmd = <STDIN>)) {
			cls();
			exit;
		}
		chomp $cmd;

		if ($cmd =~ /^\d+$/ && $cmd <= $#coms) {
			# goto turn number in $cmd
			my $start;

			if ($turn < $cmd) {
				# drawn only what's necessary
				$start = $turn;
			} else {
				# redraw everything since turn 0
				cls();
				$start = 0;
			}

			for ($start .. $cmd) {
				@glyphs = split('g', $coms[$_]);
				print_glyphs(@glyphs);
			}

			$turn = $cmd;
		}

		elsif ($cmd =~ /^s\s*(\d+)$/) {
			$slideshow = $1;
		}
	
		elsif ($turn < $#coms) {
			@glyphs = split('g', $coms[$turn]);
			print_glyphs(@glyphs);
			$turn++;
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
