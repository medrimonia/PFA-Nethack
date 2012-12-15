use 5.010;
use strict;
use warnings;

use Term::VT102;
use Term::ReadKey;
use IO::Pty::Easy;
use IO::Socket;
use IO::Select;

use Data::Dumper;

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



{	# SERVER SCOPE

	# setup socket
	my $server = IO::Socket::INET->new(
		LocalAddr => '127.0.0.1',
		LocalPort => 4242,
		Proto => 'tcp',
		Listen => 1,
		Reuse => 1,
	) || die "Can't create socket: $!";

	# setup PTY
	my $pty = IO::Pty::Easy->new();
	$pty->autoflush(1);

	(SetTerminalSize(TERMCOLS, TERMLINS, 0, 0, $pty)
		== -1) && die "Can't set terminal size";

	# create virtual screen
	my $scr = Term::VT102->new('rows' => TERMLINS, 'cols' => TERMCOLS);

	# wait for a first client before starting the whole thing
	my %clients;
	my $client = $server->accept();
	$client->autoflush(1);
	$clients{$client} = $client;

	my $s = IO::Select->new($pty, $server, values %clients);

	# IO loop
	$|++;
	$pty->spawn("nethack -X");
	while ($pty->is_active()) {

		for my $handle ($s->can_read()) {

			if ($handle == $pty) {
				my $nh_msg = $pty->read();
				$scr->process($nh_msg);

				my $msg_ref = scr2txt($scr, 1, 1);
				my $map_ref = scr2txt($scr, 2, -3);
				my $status_ref = scr2txt($scr, -2);

				foreach my $sock (values %clients) {
					$sock->send("START\n", 0);
					send_map($map_ref, $sock);
					$sock->send("END\n", 0);
				}
			}

			elsif ($handle == $server) {
				$client = $server->accept();
				$client->autoflush(1);
				$clients{$client} = $client;
				$s->add($client);
				say "New client";

				my $map_ref = scr2txt($scr, 2, -3);
				send_map($map_ref, $client);
			}

			else {
				my $rv = $handle->recv(my $cmd, 1, 0);

				unless (defined $rv && $cmd) {
					warn "recv error: closing socket";
					delete $clients{$handle};
					$s->remove($handle);
					close $handle;
				}

				print $cmd;
				defined ($pty->write($cmd, 0)) or warn "pty_write: $!";
			}
		}
	}

	close($_) foreach ($s->handles());
}


sub send_init {
}


sub send_map {
	my ($map_ref, $sock) = @_;

	$sock->send("START MAP\n", 0);
	$sock->send($$map_ref, 0);
	$sock->send("END MAP\n", 0);
}


sub scr2txt {
	my ($scr, $firstl, $lastl) = @_;

	my $msg = "";
	my $lastr = $scr->rows();

	$firstl = 1      unless ($firstl && abs($firstl) <=  $lastr);
	$lastl  = $lastr unless ($lastl  && abs($lastl ) <=  $lastr);

	# offset from bottom of screen
	$firstl = $lastr + $firstl if ($firstl < 0);
	$lastl  = $lastr + $lastl  if ($lastl  < 0);

	say "lines $firstl to $lastl";

	foreach my $row ($firstl .. $lastl) {
		$msg .= ($scr->row_plaintext($row) // "") . "\n";
	}

	return \$msg;
}
