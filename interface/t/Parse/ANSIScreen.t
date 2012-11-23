use Test::More;
use Parse::ANSIScreen;


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
	cmp_ok($line,   "==", $oldline + 42, "CUD line   1");
	cmp_ok($column, "==", $oldcolumn   , "CUD column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUD(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   "==", $oldline,   "CUD line   2");
	cmp_ok($column, "==", $oldcolumn, "CUD column 2");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUD();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   "==", $oldline + 1, "CUD line   3");
	cmp_ok($column, "==", $oldcolumn,   "CUD column 3");


	# CUF - Cursor forward
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUF(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,        "CUF line   1");
	cmp_ok($column, '==', $oldcolumn + 42, "CUF column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUF(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,    "CUF line   2");
	cmp_ok($column, '==', $oldcolumn,  "CUF column 2");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUF();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,       "CUF line   3");
	cmp_ok($column, '==', $oldcolumn + 1, "CUF column 3");


	# CUU - Cursor up
	$scr->{line}   = 100;
	$scr->{column} = 100;
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline - 42, "CUU line   1");
	cmp_ok($column, '==', $oldcolumn,    "CUU column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,   "CUU line   2");
	cmp_ok($column, '==', $oldcolumn, "CUU column 2");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline - 1, "CUU line   3");
	cmp_ok($column, '==', $oldcolumn,   "CUU column 3");


	# CUB - Cursor backward
	$scr->{line}   = 100;
	$scr->{column} = 100;
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB(42);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,        "CUB line   1");
	cmp_ok($column, '==', $oldcolumn - 42, "CUB column 1");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB(0);
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,   "CUB line   2");
	cmp_ok($column, '==', $oldcolumn, "CUB column 2");

	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline,       "CUB line   3");
	cmp_ok($column, '==', $oldcolumn - 1, "CUB column 3");


	# CUU out of screen - Cursor up
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUU($oldline + 42); # arg is too high
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', 1,          "CUU out of screen line   1"  );
	cmp_ok($column, '==', $oldcolumn, "CUU out of screen column 1");

	$scr->{line}   = 1;
	$scr->{column} = 1;
	$scr->CUU();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', 1, "CUU out of screen line   2");
	cmp_ok($column, '==', 1, "CUU out of screen column 2");


	# CUB out of screen - Cursor backward
	($oldline, $oldcolumn) = $scr->cursor();
	$scr->CUB($oldcolumn + 42); # arg is too high
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', $oldline, "CUB out of screen line   1");
	cmp_ok($column, '==', 1,        "CUB out of screen column 1");

	$scr->{line}   = 1;
	$scr->{column} = 1;
	$scr->CUB();
	($line, $column) = $scr->cursor();
	cmp_ok($line,   '==', 1, "CUB out of screen line   2");
	cmp_ok($column, '==', 1, "CUB out of screen column 2");
}


{	# Test of screen manipulation functions
	
	use Storable qw(dclone);

	my ($l, $c);
	my $scr = Parse::ANSIScreen->new();


	$scr->cursor(3, 5); # cursor on letter q
	($l, $c) = $scr->cursor();
	ok($l == 3 && $c == 5, "Set cursor position 1");	

	$scr->cursor(-2, 5);
	($l, $c) = $scr->cursor();
	ok($l == 3 && $c == 5, "Set cursor position 2");	

	$scr->cursor(7);
	($l, $c) = $scr->cursor();
	ok($l == 7 && $c == 5, "Set cursor position 3");	


	my $testscreen = [
		[qw(a b c d e f)],
		[qw(g h i j k l)],
		[qw(m n o p q r)],
		[qw(s t u v w x)],
	];

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(3, 5); # cursor on letter q
	$scr->ED();
	is_deeply($scr->{screen}, [ [qw(a b c d e f)          ],
	                            [qw(g h i j k l)          ],
	                            [qw(m n o p), undef, undef],
	                             undef,                   
	                          ], "Test ED(0) 1");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(3, 1); # cursor on letter m, left border
	$scr->ED(0);
	is_deeply($scr->{screen}, [ [qw(a b c d e f)                         ],
	                            [qw(g h i j k l)                         ],
	                            [undef, undef, undef, undef, undef, undef],
	                             undef,                   
	                          ], "Test ED(0) 2");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(1, 6); # cursor on letter f, right border
	$scr->ED(0);
	is_deeply($scr->{screen}, [ [qw(a b c d e), undef],
	                            undef,
	                            undef,
	                            undef,
	                          ], "Test ED(0) 3");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(4, 5); # cursor on letter w, bottom
	$scr->ED(0);
	is_deeply($scr->{screen}, [ [qw(a b c d e f)          ],
	                            [qw(g h i j k l)          ],
	                            [qw(m n o p q r)          ],
	                            [qw(s t u v), undef, undef],
	                          ], "Test ED(0) 4");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(3, 5); # cursor on letter q
	$scr->ED(1);
	is_deeply($scr->{screen}, [ undef,
	                            undef,
	                            [undef, undef, undef, undef, undef, qw(r)],
	                            [qw(s t u v w x)                         ],
	                          ], "Test ED(1) 1");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(4, 5); # cursor on letter w, bottom
	$scr->ED(1);
	is_deeply($scr->{screen}, [ undef,
	                            undef,
	                            undef,
	                            [undef, undef, undef, undef, undef, qw(x)],
	                          ], "Test ED(1) 2");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(2, 1); # cursor on letter g, left border
	$scr->ED(1);
	is_deeply($scr->{screen}, [ undef,
	                            [undef, qw(h i j k l)],
	                            [qw(m n o p q r)     ],
	                            [qw(s t u v w x)     ],
	                          ], "Test ED(1) 3");

	$scr->{screen} = dclone($testscreen);
	$scr->cursor(2, 6); # cursor on letter l, right border
	$scr->ED(1);
	is_deeply($scr->{screen}, [ undef,
	                            [undef, undef, undef, undef, undef, undef],
	                            [qw(m n o p q r)                         ],
	                            [qw(s t u v w x)                         ],
	                          ], "Test ED(1) 4");

	$scr->{screen} = dclone($testscreen);
	$scr->ED(2);
	is_deeply($scr->{screen}, [], "Test ED(2) 1");
}



{	# Test escape sequences
	use Data::Dumper;

	my ($l, $c);
	my $scr = Parse::ANSIScreen->new();


	$scr->parse("\e[2;5H");
	($l, $c) = $scr->cursor();
	ok($l == 2 && $c == 5, "Parse cursor position 1");

	$scr->parse("\e[2;5HHi");
	($l, $c) = $scr->cursor();
	ok($l == 2 && $c == 7, "Parse cursor position 2");

	$scr->parse("\e[H");
	($l, $c) = $scr->cursor();
	ok($l == 1 && $c == 1, "Parse cursor position 3");
	
	$scr->parse("\e[2H");
	($l, $c) = $scr->cursor();
	ok($l == 2 && $c == 1, "Parse cursor position 4");

	$scr->parse("\e[;2H");
	($l, $c) = $scr->cursor();
	ok($l == 1 && $c == 2, "Parse cursor position 5");


	my $testscreen = [
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . + . . . . + . . . . + ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . + . . . . + . . . . + ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . . . . . . . . . . . . ) ] , 
 	 	 [ qw( . . . . + . . . . + . . . . + ) ] , 
	];

	$scr->{screen} = dclone($testscreen);

	my $str = "Hi World!";
	$scr->parse("\e[2;2H".$str);
	($l, $c) = $scr->cursor();
	ok($l == 2 && $c == 2 + length($str), "wr_screen 1");
	$scr->parse("\e[K#");
	$scr->print_screen();
}


done_testing();
