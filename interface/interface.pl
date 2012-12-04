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

	(SetTerminalSize(TERMCOLS, TERMLINS, 0, 0, $pty)
	== -1) && die "Can't set terminal size";

	$pty->autoflush(1);
	$pty->spawn("nethack -X");


	# create virtual screen
	my $scr = Term::VT102->new('rows' => TERMLINS, 'cols' => TERMCOLS);


	# wait for a first client before starting the whole thing
	my @clients;
	my $client = $server->accept();
	$client->autoflush(1);
	push @clients, $client;

	my $s = IO::Select->new($pty, $server, $client);

	# IO loop
	while ($pty->is_active()) {

		for my $handle ($s->can_read()) {

			if ($handle == $pty) {
				my $nh_msg = $pty->read();
				$scr->process($nh_msg);
				send_scr($scr, @clients);
			}

			elsif ($handle == $server) {
				$client = $server->accept();
				$client->autoflush(1);
				push @clients, $client;
				$s->add($client);
				say "New client";
			}

			else {
				my $rv = $handle->recv(my $cmd, 1, 0);

				unless (defined $rv) {
					warn "unexpected disconnect: $!";
					# TODO : handle this cleanly
					exit;
				}

				say $cmd;
				defined ($pty->write($cmd, 0)) or warn "pty_write: $!";
			}
		}
	}

	close($_) foreach ($s->handles());
}


sub send_scr {
	my ($scr, @clients) = @_;

	my $msg = "";

	foreach my $row (0 .. $scr->rows()-1) {
		$msg .= ($scr->row_plaintext($row) // "") . "\n";
	}

	foreach my $client (@clients) {
		$client->send($msg, 0);
	}
}
