use 5.010;
use strict;
use warnings;

use Getopt::Std;
use Term::ReadKey;
use IO::File;
use IO::Handle;
use IO::Socket::UNIX;
use Term::ANSIScreen qw/:cursor :screen/;


my $handle;

our ($opt_f, $opt_s);
getopts("f:s:");

# data being piped to the client (read only mode)
if (! -t STDIN) {
	$handle = IO::Handle->new();
	$handle->fdopen(fileno(STDIN),"r") or die "Can't read from STDIN: $!";
	$handle->autoflush(1);

	displayloop($handle);
	$handle->close();
}

# read data from a file (read only mode)
elsif ($opt_f) {
	$handle = IO::File->new($opt_f, "r") or die "Can't open file $opt_f: $!";
	$handle->autoflush(1);

	displayloop($handle);
	$handle->close();
}

# true client, open a socket (default mode)
else {
	$handle = IO::Socket::UNIX->new(
		Type => SOCK_STREAM,
		Peer => $opt_s // "/tmp/mmsock",
	) || die "Can't connect: $!";

	$handle->autoflush(1);

	my $pid = fork();
	unless (defined $pid) {
		$handle->close();
		die "fork: $!";
	}

	if ($pid) {
		$SIG{TERM} = sub {
			# cleanup when told to quit
			$handle->close();
			my $cnt = kill 15, $pid;
			wait if ($cnt > 0);
			exit;
		};

		$SIG{CHLD} = sub {
			# what to do when the reader is dead
			ReadMode('normal'); # reset to default
			$handle->close();
			exit;
		};

		inputloop($handle);

		# tell reader to quit
		my $cnt = kill 15, $pid;
		wait if ($cnt > 0);
	}

	else {
		$SIG{TERM} = sub {
			# cleanup when told to quit
			$handle->close();
			exit;
		};

		displayloop($handle);
	}

	$handle->close();
}


sub inputloop {
	my $handle = $_[0];
	ReadMode('raw');

	while (my $key = ReadKey(0)) {
		last if ($key eq "\3"); # Ctrl-C quits
		print $handle $key;
	}

	ReadMode('normal'); # reset to default
}


sub displayloop {
	my $handle = $_[0];

	cls();
	$| = 1;
	$/ = 'E';

	my $leftover;

	while (my $msg = <$handle>) {

		my @glyphs;
		my @tmp = split('', ($leftover // '') . $msg);
		$leftover = undef;

		for (my $i = 0; $i <= $#tmp; $i++) {

			if ($tmp[$i] eq 'g') {

				if ($i + 5 <= $#tmp) {
					# got a complete glyph info
					push @glyphs, join('', @tmp[$i+1 .. $i+5]);
				} else {
					# truncated glyph info goes in $leftover
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
