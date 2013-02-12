use strict;
use warnings;

use Time::HiRes qw/sleep/;
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
my @coms = split("ES", $replay);

my @glyphs = split('g', $coms[0]);
print_glyphs(@glyphs);

while (1) {
	# Prompt
	locate 1,1;
	clline();
	print "> ";
	my $nbr = <STDIN>;

	# goto turn number $nbr
	if ($nbr =~ /^\d+$/ && $nbr <= $#coms) {
		my $start;

		if ($i < $nbr) {
			$start = $i + 1;
		} else {
			cls();
			$start = 0;
		}

		for ($start .. $nbr) {
			@glyphs = split('g', $coms[$_]);
			print_glyphs(@glyphs);
		}

		$i = $nbr;
	}
	
	else {
		$i++;
		@glyphs = split('g', $coms[$i]);
		print_glyphs(@glyphs);
	}

	#sleep(0.01);
}


sub print_glyphs {
	local $| = 0;

	for (@_) {
		my ($y, $x, $g) = unpack("WWa");

		if (defined $g) {
			locate $x+1, $y+1;
			print $g;
		}
	}
}
