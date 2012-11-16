use Test::More;
use Parse::ANSIScreen;

use Data::Dumper;

my @scr = (
	[qw(a b c d e f)],
	[qw(g h i j k l)],
	[qw(m n o p q r)],
	[qw(s t u v w x)],
);

$ANSIScreen->{screen} = \@scr;

{   # Test cursor movements 

	my ($line, $column);
	my ($oldline, $oldcolumn);
	my $scr = Parse::ANSIScreen->new();
	

	($line, $column) = $scr->cursor();
	ok($line == 1 && $column == 1, "Initial cursor position");

	# CUD - Cursor down
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUD(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   "==", $oldline + 42, "CUD line 1"  );
	cmp_ok($column, "==", $oldcolumn   , "CUD column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUD(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   "==", $oldline,   "CUD line 2"  );
	cmp_ok($column, "==", $oldcolumn, "CUD column 2");


	# CUF - Cursor forward
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUF(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,        "CUF line 1"  );
	cmp_ok($column, '==', $oldcolumn + 42, "CUF column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUF(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,    "CUF line 2"  );
	cmp_ok($column, '==', $oldcolumn,  "CUF column 2");


	# CUU - Cursor up
	$scr->{line}   = 100;
	$scr->{column} = 100;
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline - 42, "CUU line 1"  );
	cmp_ok($column, '==', $oldcolumn,    "CUU column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,   "CUU line 2"  );
	cmp_ok($column, '==', $oldcolumn, "CUU column 2");


	# CUB - Cursor backward
	$scr->{line}   = 100;
	$scr->{column} = 100;
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,        "CUB line 1"  );
	cmp_ok($column, '==', $oldcolumn - 42, "CUB column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,   "CUB line 2"  );
	cmp_ok($column, '==', $oldcolumn, "CUB column 2");


	# CUU out of screen - Cursor up
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU($oldline + 42); # arg is too high
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', 1,          "CUU out of screen line"  );
	cmp_ok($column, '==', $oldcolumn, "CUU out of screen column");


	# CUB out of screen - Cursor backward
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB($oldcolumn + 42); # arg is too high
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline, "CUB out of screen line"  );
	cmp_ok($column, '==', 1,        "CUB out of screen column");
}

done_testing();
