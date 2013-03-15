use strict;
use warnings;

my $header = <<'EOH';
\documentclass[border=10pt]{standalone}
\usepackage{tikz}
\begin{document}
EOH

my $footer = <<'EOF';
\end{document}
EOF


if ($#ARGV < 0) {
	print "Usage: perl $0 <replay file>\n";
	exit;
}


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

for (my $j = 0, my $i = 0; $j <= $#tmp; $j++) {

	if ($tmp[$j] eq 'C') {
		$offset += 25;
	}

	elsif (($tmp[$j] eq 'g') && ($j + 5 <= $#tmp)) {
		my $glyph = join('', @tmp[$j+1 .. $j+5]);
		my ($y, $x, $g, $c) = unpack("CCaS", $glyph);

		$x += $offset;

		if ($g ne '@') {
			$map->[$x]->[$y] = $g;
		} elsif ($c < 400) {
			$btcnt->[$x]->[$y] += 1;
			$max = ($max > $btcnt->[$x]->[$y]) ? $max : $btcnt->[$x]->[$y];
		}

		$j += 5;
	}
}

print $header;
print '\begin{tikzpicture} [scale=0.3]', "\n";

for my $x (0 .. $#{$map}) {
	my $line = $map->[$x];
	for my $y (0 .. $#{$line}) {
		my $glyph = $line->[$y];
		my $cnt = $btcnt->[$x]->[$y];
		my $color = (defined $cnt)
			? int(100 * $cnt / $max)
			: undef;
		node($x, $y, $glyph, $color) if (defined $glyph);
	}
}

print '\end{tikzpicture}', "\n";
print $footer;


sub node {
	my ($x, $y, $label, $color) = @_;
	# Don't forget the rotation!
	print '\node ';

	if (defined $color) {
		print "[fill=red!$color!yellow] ";
	}
	
	print "at ($y, -$x) {\\verb!$label!};\n";
}
