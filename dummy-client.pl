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

	cls();
	my @glyphs;
	my $leftover;

	while (my $msg = <$sock>) {

		my @tmp = split('', ($leftover // '') . $msg);
		$leftover = undef;

		for (my $i = 0; $i <= $#tmp; $i++) {

			if ($tmp[$i] eq 'g') {

				# complete glyph info
				if ($i + 5 <= $#tmp) {
					push @glyphs, join('', @tmp[$i+1 .. $i+5]);
				}
				
				# truncated glyph info goes in $leftover
				else {
					print STDERR "POUET : ";
					$leftover = join('', @tmp[$i .. $#tmp]);
					last;
				}

				$i += 5;
			}
		}

		print_glyphs(@glyphs);
	}
}

close $sock;


sub print_glyphs {
	local $| = 0;

	for (@_) {
		my ($y, $x, $g, $code) = unpack("WWaS");

		if (defined $g) {
			locate $x+2, $y;
			print $g;
		}
	}
}
