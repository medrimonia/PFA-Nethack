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
	ReadMode('raw');

	while (my $key = ReadKey(0)) {
		print $sock $key;
	}

	ReadMode('normal'); # reset to default
}

else {
	$| = 1;
	$/ = 'E';

	my $s = IO::Select->new($sock);

	cls();

	while(my $msg = <$sock>) {

		while ($s->can_read(0.05)) {
			$msg .= <$sock>;
		}

		my @glyphs;
		my @tmp = split('(g)', $msg);

		for my $i (0 .. $#tmp - 1) {
			if ($tmp[$i] eq 'g') {
				push @glyphs, $tmp[$i+1];
			}
		}

		print_glyphs(@glyphs);
	}
}

close $sock;


sub print_glyphs {
	local $| = 0;

	for (@_) {
		my ($y, $x, $g) = unpack("WWa");

		if (defined $g) {
			locate $x, $y;
			print $g;
		}
	}
}
