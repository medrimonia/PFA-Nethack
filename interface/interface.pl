use 5.014;
use strict;
use warnings;

use Term::VT102;
use Term::ReadKey;
use IO::Pty::Easy;

# Messages line ................ --more--
# ----------------------------------------
# |                   |                  |
# |                   |                  |
# |      MAP 21x80    |   MENU 21x80     |
# |                   |                  |
# |                   |                  |
# ----------------------------------------
# Status line 1
# Status line 2

use constant {
	TERMCOLS => 160,
	TERMLINS => 24, # nethack won't use more lines
};


my $pty = IO::Pty::Easy->new();

my (undef, undef, $xpix, $ypix) = GetTerminalSize();
(SetTerminalSize(TERMCOLS, TERMLINS, $xpix, $ypix, $pty)
	== -1) && die "Can't set terminal size";

$pty->autoflush(1);
$pty->spawn("nethack -X");


defined (my $pid = fork()) or die "fork: $!";

# parent - show the game
if ($pid) {

	open (my $log, ">", "log.txt");
	select($log); $|++;

	my $scr = Term::VT102->new('rows' => TERMLINS, 'cols' => TERMCOLS);

    while ($pty->is_active()) {
        my $nh_msg = $pty->read();
		
		$scr->process($nh_msg);

		for my $row (0 .. TERMLINS-1) {
			my $str = $scr->row_plaintext($row);
			print "$str\n" if (defined $str);
		}
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
