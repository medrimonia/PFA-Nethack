use 5.014;
use strict;
use warnings;

use IO::Pty::Easy;
use Term::ReadKey;

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
		chomp $nh_msg;
		$scr->parse($nh_msg);
		$scr->print_screen();
	}
}

# child - catch key press events
else {
	ReadMode(4);
	while ($pty->is_active()) {
        my $key = ReadKey(0);
        $pty->write($key);
    }
}

$pty->close();
