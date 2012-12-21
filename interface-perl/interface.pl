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


$|++;

socketpair(my $s1, my $s2, AF_UNIX, SOCK_STREAM, 0)
	or die "socketpair: $!";
$s1->autoflush(1);
$s2->autoflush(1);

defined (my $pid = fork())
	or die "fork: $!";

# key presses handling
if ($pid) {
	close $s2;
	ReadMode(3);

	while (my $key = ReadKey(0)) {
		print $s1 $key;
	}

	close $s1;
	ReadMode(0);
}

# server
else {
	close $s1;

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
	$SIG{INT}  = sub { $pty->close() };
	$SIG{TERM} = sub { $pty->close() };
	$pty->autoflush(1);

	(SetTerminalSize(TERMCOLS, TERMLINS, 0, 0, $pty)
		== -1) && die "Can't set terminal size";

	# create virtual screen
	my $scr = Term::VT102->new('rows' => TERMLINS, 'cols' => TERMCOLS);

	# spawn NetHack
	my $nhexec = $ARGV[0] // "nethack";
	$pty->spawn($nhexec . " -X") or die "pty_spawn: $!";

	# IO loop
	my %clients;
	my $s = IO::Select->new($pty, $server, $s2);
	while ($pty->is_active()) {

		for my $handle ($s->can_read()) {

			if ($handle == $pty) { # update from the game
				my $nh_msg = $pty->read();
				$scr->process($nh_msg);

				print ${ scr2txt($scr) };
				send_map($scr, $_) foreach (values %clients);
			}

			elsif ($handle == $s2) { # Keyboard event
				if (my $key = getc($s2)) {
					$pty->write($key, 0);
				} else {
					warn "getc: $!";
				}
			}

			elsif ($handle == $server) { # new client
				my $client = $server->accept();
				$client->autoflush(1);
				$clients{$client} = $client;
				$s->add($client);
				say "New client";

				send_init($scr, $client);
			}

			else { # client/bot talking
				my $rv = $handle->recv(my $botcmd, 64);

				if (defined $rv && $botcmd) {
					my $nhcmd = botcmd2nhcmd($botcmd);
					defined ($pty->write($nhcmd, 0)) or warn "pty_write: $!";

					# wait for an update of the game
					my $nh_msg = $pty->read(1/10); # 0.1s timeout
					$scr->process($nh_msg) if (defined $nh_msg);

					print ${ scr2txt($scr) };
					# send the result of the command
					send_map($scr, $_) foreach (values %clients);
				}

				else {
					warn "recv error: closing socket";
					delete $clients{$handle};
					$s->remove($handle);
					close $handle;
				}
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
	            "END",
				"",
			);

	$sock->send(join("\n", @msgs), 0);
}


sub send_map {
	my ($scr, $sock) = @_;

	my @msgs = ("START",
	            "START MAP",
	            ${ get_map($scr) },
	            "END MAP",
	            "END",
				"",
			);

	$sock->send(join("\n", @msgs), 0);
}


sub get_map {
	my ($scr) = @_;
	return scr2txt($scr, 2, -3, 1, 80);
}

sub get_menu {
	my ($scr) = @_;
	return scr2txt($scr, 2, -3, -80);
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
	# screen, first line, last line, first column, last column
	my ($scr, $firstl, $lastl, $firstc, $lastc) = @_;

	my $msg = "";
	my $nrows = $scr->rows();
	my $ncols = $scr->cols();

	$firstl = 1      unless ($firstl && abs($firstl) <=  $nrows);
	$lastl  = $nrows unless ($lastl  && abs($lastl ) <=  $nrows);

	$firstc = 1      unless ($firstc && abs($firstc) <=  $ncols);
	$lastc  = $ncols unless ($lastc  && abs($lastc ) <=  $ncols);

	# offset from bottom of screen
	$firstl = $nrows + $firstl if ($firstl < 0);
	$lastl  = $nrows + $lastl  if ($lastl  < 0);

	# offset from right end of screen
	$firstc = $ncols + $firstc if ($firstc < 0);
	$lastc  = $ncols + $lastc  if ($lastc  < 0);

	foreach my $row ($firstl .. $lastl) {
		$msg .= ($scr->row_plaintext($row, $firstc, $lastc) // "") . "\n";
	}

	return \$msg;
}


BEGIN {
	my %dirs = (
		NORTH      => "k",
		NORTH_WEST => "y",
		NORTH_EAST => "u",
		SOUTH      => "j",
		SOUTH_WEST => "b",
		SOUTH_EAST => "n",
		WEST       => "h",
		EAST       => "l",
	);

	sub botcmd2nhcmd {
		my ($botcmd) = @_;

		if ($botcmd =~ /^MOVE (\w+)$/) {
			if (exists $dirs{$1}) {
				return $dirs{$1};
			}
		}

		elsif ($botcmd =~ /^OPEN (\w+)$/) {
			if (exists $dirs{$1}) {
				return "o" . $dirs{$1};
			}
		}

		elsif ($botcmd =~ /^FORCE (\w+)$/) {
			if (exists $dirs{$1}) {
				# \4 = ^D
				return "\4" . $dirs{$1};
			}
		}

		# default
		return $botcmd;
	}
}

