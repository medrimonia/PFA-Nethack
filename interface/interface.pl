use 5.014;
use strict;
use warnings;

use IO::Pty::Easy;
use Parse::ANSIScreen;


my $pty = IO::Pty::Easy->new();
$pty->autoflush(1);
$pty->spawn("nethack -X | tee log.txt");


defined (my $pid = fork()) or die "fork: $!";

# parent - show the game
if ($pid) {
	my $scr = Parse::ANSIScreen->new();

    while ($pty->is_active()) {
        my $nh_msg = $pty->read();
		
		$nh_msg =~ s/\010/\e[D/g; # replace \b by the CUB command.

		$scr->parse($nh_msg);
		system("clear");
		$scr->print_screen();
	}
}

# child - catch commands
else {
	require IO::Socket::INET;

	my $sock = IO::Socket::INET->new(
		LocalAddr => '127.0.0.1',
		LocalPort => 9999,
		Proto => 'udp',
		Reuse => 1,
	) || die "Can't create socket: $!";
	
	while ($sock->recv(my $cmd, 1, 0)) {
		warn "Can't write!" if ($pty->write($cmd, 0) < 1);
	}

	close $sock;
}

$pty->close();
