use strict;
use warnings;

use Time::HiRes qw/sleep/;
use Term::ANSIScreen qw/:cursor :screen/;


my $filename = $ARGV[0] // "replay";
open(my $fh, '<', $filename) or die "Can't open file $filename: $!";
$/ = undef; #slurp!
my $replay = <$fh>;

close $fh;

cls;
$| = 1;

my @coms = split("ES", $replay);

for (@coms) {
	my @glyphs = split('g');

	for (@glyphs) {
		my ($y, $x, $g) = unpack("WWa");

		if (defined $g) {
			locate $x, $y;
			print $g;
		}
	}

	sleep(0.05);
}

