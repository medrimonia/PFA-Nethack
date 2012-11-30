use 5.014;
use strict;
use warnings;

use Term::ReadKey;
use IO::Socket::INET;

ReadMode(3);

my $sock = IO::Socket::INET->new(
	PeerAddr => '127.0.0.1',
	PeerPort => 9999,
	Proto => 'udp'
) || die "Can't connect: $!";


$| = 1;

while (my $key = ReadKey(0)) {
	print $key;
	$sock->send($key);
}

ReadMode(0); # reset to default

close $sock;
