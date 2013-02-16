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

	if ($slideshow) {
		ReadMode('cbreak');

		for (my $t = $i; $t <= $#coms; $i++, $t++) {
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

			if ($i < $cmd) {
				# drawn only what's necessary
				$start = $i;
			} else {
				# redraw everything since turn 0
				cls();
				$start = 0;
			}

			for ($start .. $cmd) {
				@glyphs = split('g', $coms[$_]);
				print_glyphs(@glyphs);
			}

			$i = $cmd;
		}

		elsif ($cmd =~ /^s\s*(\d+)$/) {
			$slideshow = $1;
		}
	
		elsif ($i < $#coms) {
			@glyphs = split('g', $coms[$i]);
			print_glyphs(@glyphs);
			$i++;
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
