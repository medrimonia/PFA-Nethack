use 5.014;
use strict;
use warnings;

use Term::ReadKey;
use IO::Socket::INET;


my $sock = IO::Socket::INET->new(
	PeerAddr => '127.0.0.1',
	PeerPort => 4242,
	Proto => 'tcp'
) || die "Can't connect: $!";

$sock->autoflush(1);


defined (my $pid = fork()) or die "fork: $!";

my %dirs = (
	"k" => "NORTH",
	"u" => "NORTH_WEST",
	"i" => "NORTH_EAST",
	"j" => "SOUTH",
	"b" => "SOUTH_WEST",
	"n" => "SOUTH_EAST",
	"h" => "WEST",
	"l" => "EAST",
);

if ($pid) {
	ReadMode(3);

	while (my $key = ReadKey(0)) {
		if (exists $dirs{$key}) {
			print $sock "MOVE $dirs{$key}";
		}

		else {
			print $sock $key;
		}
	}

	ReadMode(0); # reset to default
}

else {
	$| = 1;
	print while(<$sock>);
}

close $sock;
