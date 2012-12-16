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

				send_map($scr, $_) foreach (values %clients);
			}

			elsif ($handle == $server) {
				$client = $server->accept();
				$client->autoflush(1);
				$clients{$client} = $client;
				$s->add($client);
				say "New client";

				send_init($scr, $client);
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
	my ($scr, $sock) = @_;

	my @msgs = ("START",
	            "MAP_HEIGHT 22",
	            "MAP_WIDTH 80",
	            "START MAP",
	            ${ get_map($scr) },
	            "END MAP",
	            "START STATUS",
	            ${ get_status($scr) },
	            "END STATUS",
				"",
			);

	$sock->send(join("\n", @msgs), 0);
}


sub send_map {
	my ($scr, $sock) = @_;

	my @msgs = ("START MAP",
	            ${ get_map($scr) },
	            "END MAP",
	            "START STATUS",
	            ${ get_status($scr) },
	            "END STATUS",
				"",
			);

	$sock->send(join("\n", @msgs), 0);
}


sub get_map {
	my ($scr) = @_;
	return scr2txt($scr, 2, -3);
}

sub get_nhmsg {
	my ($scr) = @_;
	return scr2txt($scr, 1, 1);
}

sub get_status {
	my ($scr) = @_;
	return scr2txt($scr, -2);
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
