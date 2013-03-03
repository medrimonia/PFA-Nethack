use 5.010;
use strict;
use warnings;

use Term::ReadKey;
use IO::Socket::INET;


my $sock = IO::Socket::UNIX->new(
	Type => SOCK_STREAM,
	Peer => $ARGV[0] // "/tmp/mmsock",
) || die "Can't connect: $!";

$sock->autoflush(1);


defined (my $pid = fork()) or die "fork: $!";

if ($pid) {
	ReadMode('cbreak');

	while (my $key = ReadKey(0)) {
		print $sock $key;
	}

	ReadMode('normal'); # reset to default
}

else {
	$| = 1;
	print while(<$sock>);
}

close $sock;
