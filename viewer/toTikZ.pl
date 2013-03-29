use strict;
use warnings;

use Getopt::Std;
use Scalar::Util qw(looks_like_number);

my $usage = <<EOU;
Usage: perl $0 [-f|-e] [-s <scale>] <replay file>
	-f : generate full latex document with header, etc...
	-s : scale pictures (default 0.3)
	-e : level exploration mode
EOU

my $scale = 0.3;

my $header = <<'EOH';
\documentclass[border=10pt]{standalone}
\usepackage{tikz}
\begin{document}
EOH

my $footer = <<'EOF';
\end{document}
EOF

our ($opt_h, $opt_f, $opt_e, $opt_s);
getopts("hfes:");

if ($#ARGV < 0 || $opt_h) {
	print $usage;
	exit;
}

$scale = $opt_s if (defined $opt_s && looks_like_number($opt_s));

my @tmp;

{	# slurp from $filename
	local $/ = undef;

	my $filename = $ARGV[0];
	open(my $fh, '<', $filename)
		or die "Can't open file $filename: $!";
	my $replay = <$fh>;
	close $fh;

	@tmp = split('', $replay);
}

# offset used to display multiple levels
my $offset = 0;

my $map = [];
my $max = 1;
my $btcnt = [];

my $turn = 0;
my $max_discov_turn = 0;
my $discov_turn = [];

for (my $j = 0, my $i = 0; $j <= $#tmp; $j++) {

	if ($tmp[$j] eq 'C') {
		$offset += 23;
	}

	elsif ($tmp[$j] eq 'E') {
		$turn++;
	}

	elsif (($tmp[$j] eq 'g') && ($j + 5 <= $#tmp)) {
		my $glyph = join('', @tmp[$j+1 .. $j+5]);
		my ($y, $x, $g, $c) = unpack("CCaS", $glyph);

		$x += $offset;

		# glyphs codes between 2344 and 2410 are part of a dungeon. See the
		# dumped symbol list.
		if ($c >= 2344 && $c <= 2410 ) {
			$map->[$x]->[$y] = $g;
			if (! defined $discov_turn->[$x]->[$y]) {
				$max_discov_turn = $turn;
				$discov_turn->[$x]->[$y] = $turn;
			}
		}
		
		# codes below 400 with @ as a glyph are codes used for the player
		elsif ($c < 400 && $glyph eq '@') {
			$btcnt->[$x]->[$y] += 1;
			$max = ($max > $btcnt->[$x]->[$y]) ? $max : $btcnt->[$x]->[$y];
		}

		$j += 5;
	}
}

if (defined $opt_f) {
	print $header;
}

print '\begin{tikzpicture}', "[scale=$scale]\n";

for my $x (0 .. $#{$map}) {
	my $line = $map->[$x];
	for my $y (0 .. $#{$line}) {
		my $colorvalue;
		my $glyph = $line->[$y];

		next unless (defined $glyph);

		if (defined $opt_e) {
			my $cnt = $discov_turn->[$x]->[$y];
			$colorvalue = (defined $cnt)
				? int(100 * $cnt / $max_discov_turn)
				: undef;
			node($x, $y, $glyph, $colorvalue, "blue", "yellow");
		}

		else {
			my $cnt = $btcnt->[$x]->[$y];
			$colorvalue = (defined $cnt)
				? int(100 * $cnt / $max)
				: undef;
			node($x, $y, $glyph, $colorvalue, "red", "yellow");
		}
	}
}

print '\end{tikzpicture}', "\n";

if (defined $opt_f) {
	print $footer;
}


sub node {
	my ($x, $y, $label, $colorvalue, $color1, $color2) = @_;
	$color1 //= "red";
	$color2 //= "yellow";
	print '\node ';

	if (defined $colorvalue) {
		print "[fill=$color1!$colorvalue!$color2] ";
	}
	
	# Don't forget the rotation!
	print "at ($y, -$x) {\\verb!$label!};\n";
}
