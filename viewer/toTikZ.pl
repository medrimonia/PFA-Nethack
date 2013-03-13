use strict;
use warnings;

my $header = <<'EOH';
\documentclass[landscape]{article}
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


print $header;
print '\begin{tikzpicture} [scale=0.4]', "\n";

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

for (my $j = 0, my $i = 0; $j <= $#tmp; $j++) {

	if (($tmp[$j] eq 'g') && ($j + 5 <= $#tmp)) {
		my $glyph = join('', @tmp[$j+1 .. $j+5]);
		my ($y, $x, $g, $c) = unpack("CCaS", $glyph);
		node($x, $y, $g) if ($g ne '@');
		$j += 5;
	}
}

print '\end{tikzpicture}', "\n";
print $footer;


sub node {
	my ($x, $y, $label) = @_;
	# Don't forget the rotation!
	print '\node at (', $y, ', ', -$x, ') {\\verb!', $label, "!};\n";
}
