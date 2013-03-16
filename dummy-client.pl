use 5.010;
use strict;
use warnings;

use IO::Select;
use Term::ReadKey;
use IO::Socket::UNIX;
use Term::ANSIScreen qw/:cursor :screen/;


my $sock = IO::Socket::UNIX->new(
	Type => SOCK_STREAM,
	Peer => $ARGV[0] // "/tmp/mmsock",
) || die "Can't connect: $!";

$sock->autoflush(1);


defined (my $pid = fork()) or die "fork: $!";

if ($pid) {
	$SIG{TERM} = sub {
		# cleanup when told to quit
		close $sock;
		my $cnt = kill 15, $pid;
		wait if ($cnt > 0);
		exit;
	};

	$SIG{CHLD} = sub {
		# what to do when the reader is dead
		ReadMode('normal'); # reset to default
		close $sock;
		exit;
	};

	ReadMode('raw');

	while (my $key = ReadKey(0)) {
		last if ($key eq "\3"); # Ctrl-C quits
		print $sock $key;
	}

	ReadMode('normal'); # reset to default
	close $sock;

	# tell reader to quit
	my $cnt = kill 15, $pid;
	wait if ($cnt > 0);
}

else {
	$| = 1;
	$/ = 'E';

	$SIG{TERM} = sub {
		# cleanup when told to quit
		close $sock;
		exit;
	};

	cls();
	my $leftover;

	while (my $msg = <$sock>) {

		my @glyphs;
		my @tmp = split('', ($leftover // '') . $msg);
		$leftover = undef;

		for (my $i = 0; $i <= $#tmp; $i++) {

			if ($tmp[$i] eq 'g') {

				# got a complete glyph info
				if ($i + 5 <= $#tmp) {
					push @glyphs, join('', @tmp[$i+1 .. $i+5]);
				}
				
				# truncated glyph info goes in $leftover
				else {
					$leftover = join('', @tmp[$i .. $#tmp]);
					last;
				}

				$i += 5;
			}

			elsif ($tmp[$i] eq 'C') {
				cls();
			}
		}

		print_glyphs(\@glyphs);
	}

	close $sock;
}


sub print_glyphs {
	local $| = 0;
	my ($ref) = @_;

	for (@$ref) {
		my ($y, $x, $g, $code) = unpack("CCaS");

		if (defined $g) {
			locate $x+2, $y;
			print $g;
		}
	}
}
