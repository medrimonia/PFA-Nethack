use v5.10;
use strict;
use warnings;

use Carp;
use Term::ReadKey;
use Time::HiRes qw/sleep/;
use Term::ANSIScreen qw/:cursor :screen/;

my $usage = <<EOU;
Usage: perl $0 <replay file>

Commands are:
  `j` : go to next turn
  `k` : go to previous turn
  `:` : show the prompt for more complex commands
  `q` : quit

The prompt accepts these commands:
  `N` : goto turn number N.
  `s N` : slideshow with N turns per second. Any key stops the slideshow.
  `b N` : backward slideshow with N turns per second. Any key stops the slideshow.
 
Note : 'turns' are not in-game turns, they are communication turns. This means
that each time NetHacks' kernel wait for a command counts as a turn. For
instance, "jjj" counts as 3 turns, "3j" counts as 2 turns. However actions
that are followed by a direction count as 1 turn ("oj", "^Dk", etc).
EOU

if ($#ARGV < 0) {
	print $usage;
	exit;
}


my @cmds;           # commands for each turn (clear screen etc)
my @cmds_reversed;  # commands when going backward
my @coms;           # array of glyphs to display for each turn
my @coms_reversed;  # array of glyphs that cancel those stored in @coms

{	my @level_marks = (0); # store turn numbers upon level change

	sub level_push {
		my ($turn, $coms) = @_;
		push @level_marks, $turn;
		cls();
	}

	sub level_pop {
		my ($turn, $coms) = @_;
		pop @level_marks;

		unless (@level_marks > 0) {
			carp "Poping non existant level!";
			return;
		}

		cls();

		# re-print everything from the previous level
		local $| = 0;
		my $start = $level_marks[$#level_marks];
		print_glyphs($_, \@coms) for ($start .. $turn)
	}

	sub print_glyphs {
		local $| = 0;
		my ($turn, $coms) = @_;
		my $glyphs = $coms->[$turn];

		unless (defined $glyphs) {
			carp "No glyphs!";
			return;
		}
		
		for (@$glyphs) {
			my ($y, $x, $g) = @$_;

			if (defined $g) {
				locate $x+2, $y+1;
				print $g;
			}
		}
	}
}


{	my @tmp;

	{	# slurp from file
		local $/ = undef;

		my $filename = $ARGV[0];
		open(my $fh, '<', $filename)
			or die "Can't open file $filename: $!";
		my $replay = <$fh>;
		close $fh;

		@tmp = split('', $replay);
	}

	# build @coms and @coms_reversed
	my $tmpmap = [];   # remember glyphs position
	my $glyphs = [];   # glyphs for one turn
	my $glyphs_r = []; # glyphs to cancel those stored in $glyphs

	for (my ($i, $j) = (0, 0); $j < @tmp; $j++) {

		if (($tmp[$j] eq 'g') && ($j + 5 < @tmp)) {

			# g<x:byte><y:byte><glyph:byte><code:short> : total = 5 bytes
			my $glyph = join('', @tmp[$j+1 .. $j+5]);
			my ($y, $x, $g, $c) = unpack("CCaS", $glyph);

			push    @$glyphs,   [$y, $x, $g];
			unshift @$glyphs_r, [$y, $x, $tmpmap->[$x]->[$y] // " "];

			$tmpmap->[$x]->[$y] = $g;
			$j += 5;
		}

		elsif ($tmp[$j] eq 'C') {
			# clear window instruction
			$tmpmap = [];
			push @{ $cmds[$i] },          \&level_push;
			push @{ $cmds_reversed[$i] }, \&level_pop;
		}

		elsif ($tmp[$j] eq 'E') {
			# 'E' marks the end of an update for a turn
			$coms[$i]          = $glyphs;
			$coms_reversed[$i] = $glyphs_r;

			push @{ $cmds[$i] },         \&print_glyphs;
			push @{ $cmds_reversed[$i]}, \&print_glyphs;

			$glyphs   = [];
			$glyphs_r = [];

			$i++;
		}
	}
}


cls();
$| = 1;

my $turn = 0;
my $slideshow = 0;
my $slideshow_reversed = 0;

# print first set of glyphs (initial map)
print_glyphs(0, \@coms);

ReadMode('cbreak');

while (1) {
	locate 1,1; clline(); print "turn $turn";

	if ($slideshow) {

		if ($turn < $#coms) {
			sleep(1./$slideshow);

			$turn++;
			$_->($turn, \@coms)
				foreach (@{ $cmds[$turn] });

			$slideshow = 0 if (defined ReadKey(-1));
		}
		
		else {
			$slideshow = 0;
		}
	}

	elsif ($slideshow_reversed) {
		if ($turn > 0) {
			sleep(1./$slideshow_reversed);

			$turn--;
			$_->($turn+1, \@coms_reversed)
				foreach (@{ $cmds_reversed[$turn+1] });

			$slideshow_reversed = 0 if (defined ReadKey(-1));
		}
		
		else {
			$slideshow_reversed = 0;
		}
	}

	else {
		my $key = ReadKey(0);

		if ($key eq 'j' && $turn < $#coms) {
			$turn++;
			$_->($turn, \@coms)
				foreach (@{ $cmds[$turn] });
		}

		elsif ($key eq 'k' && $turn > 0) {
			$turn--;
			$_->($turn+1, \@coms_reversed)
				foreach (@{ $cmds_reversed[$turn+1] });
		}

		elsif ($key eq 'q') {
			cls();
			last;
		}

		elsif ($key eq ':') {
			my $cmd;

			# prompt
			locate 1,1; clline(); print "turn $turn : ";
			ReadMode('normal');
			$cmd = <STDIN>;
			chomp $cmd;
			ReadMode('cbreak');

			if ($cmd =~ /^\d+$/ && $cmd < @coms) {
				# goto turn number in $cmd
				local $| = 0;

				if ($turn <= $cmd) {
					# going forward
					while ($turn != $cmd) {
						$turn++;
						$_->($turn, \@coms)
							foreach (@{ $cmds[$turn] });
					}
				}
				
				elsif (($turn - $cmd) > $cmd) {
					# going backward but faster to redraw from turn 0
					cls();
					$turn = -1;
					while ($turn != $cmd) {
						$turn++;
						$_->($turn, \@coms)
							foreach (@{ $cmds[$turn] });
					}
				}

				else {
					# going backward
					while ($turn != $cmd) {
						$turn--;
						$_->($turn+1, \@coms_reversed)
							foreach (@{ $cmds_reversed[$turn+1] });
					}
				}
			}

			elsif ($cmd =~ /^s\s*(\d+)$/) {
				$slideshow = $1;
			}
			
			elsif ($cmd =~ /^b\s*(\d+)$/) {
				$slideshow_reversed = $1;
			}
		}
	}
}

ReadMode('normal');

