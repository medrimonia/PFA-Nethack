package Parse::ANSIScreen;

use v5.10;
use strict;
use warnings;

use Carp;


sub new {
	my $class = shift;
	my ($CSI) = @_;

	my %self = (
		CSI     => $CSI // qr/\e\[/,
		line    => 1,
		column  => 1,
		screen  => [],
	);

	return bless \%self, $class;
}


sub parse {
	my $self = shift;
	my ($str) = @_;

	chomp $str;

	my @sequences = split($self->{CSI}, $str);
	#print Dumper(\@sequences);

	foreach (@sequences) {
		my $s;

		# Move cursor
		if    (/^(\d*)A(.*)/) { $self->CUU($1); $s = $2; }
		elsif (/^(\d*)B(.*)/) { $self->CUD($1); $s = $2; }
		elsif (/^(\d*)C(.*)/) { $self->CUF($1); $s = $2; }
		elsif (/^(\d*)D(.*)/) { $self->CUB($1); $s = $2; }

		# Set absolute cursor position
		elsif (/^H(.*)/)            { $self->CUP();       $s = $3; }
		elsif (/^(\d*);(\d*)H(.*)/) { $self->CUP($1, $2); $s = $3; }

		# Delete data
		elsif (/^(\d*)J(.*)/) { $self->ED($1); $s = $2; }
		elsif (/^(\d*)K(.*)/) { $self->EL($1); $s = $2; }

		# Sequences not yet caught
		else { print "Uncaught: $_\n"; $s = $_; }

		$self->wr_screen($s) if (defined $s);
	}

	return 1;
}


sub wr_screen {
	my $self = shift;
	my ($str) = @_;

	return unless (defined $str);

	my $l = $self->{line};

	for (split(//, $str)) {
		my $c = $self->{column}++;
		# Screen coordinates start from 1, not 0
		$self->{screen}->[$l-1]->[$c-1] = $_;
	}
}


sub print_screen {
	my $self = shift;

	foreach my $line (@{ $self->{screen} }) {
		foreach (@$line) { defined $_ ? print : print " "; }
		print "\n";
	}
}


sub dump {
	my $self = shift;

	return $self->{line}, $self->{column}, $self->{screen};
}


sub cursor {
	my $self = shift;
	my ($l, $c) = @_;

	if (defined $l && defined $c) {
		if ($l > 0 && $c > 0) {
			$self->{line}   = $l;
			$self->{column} = $c;
		}
	}

	return ($self->{line}, $self->{column});
}


sub CUU {
	# Move cursor up
	my $self = shift;
	my ($n) = @_;

	$n //= 1;
	return if ($n < 1);

	$self->{line} > $n ? ($self->{line} -= $n) : ($self->{line} = 1);
}


sub CUD {
	# Move cursor down
	my $self = shift;
	my ($n) = @_;

	$n //= 1;
	return if ($n < 1);

	$self->{line} += $n;
}


sub CUF {
	# Move cursor forward
	my $self = shift;
	my ($n) = @_;

	$n //= 1;
	return if ($n < 1);

	$self->{column} += $n;
}


sub CUB {
	# Move cursor backward
	my $self = shift;
	my ($n) = @_;

	$n //= 1;
	return if ($n < 1);

	$self->{column} > $n ? ($self->{column} -= $n) : ($self->{column} = 1);
}


sub CUP {
	# Set absolute cursor position
	my $self = shift;
	my ($l, $c) = @_;

	$l //= 1;
	return if ($l < 1);
	$c //= 1;
	return if ($c < 1);

	$self->cursor($l, $c);
}


sub ED {
	# Delete data
	my $self = shift;
	my ($n) = @_;

	$n //= 0; # default behavior if no argument

	# Screen coordinates start from 1, not 0

	if ($n == 0) {
		my $l = $self->{line} - 1;
		my $c = $self->{column} - 1;

		my $scr      = $self->{screen};
		my $nlines   = scalar @{ $scr       } - 1;
		my $ncolumns = scalar @{ $scr->[$l] } - 1;

		if ($c <= $ncolumns) {
			$self->{screen}->[$l]->[$_] = undef for ($c .. $ncolumns);
		}

		if ($l < $nlines) {
			$self->{screen}->[$_] = undef for ($l+1 .. $nlines);
		}
	}

	elsif ($n == 1) {
		my $l = $self->{line} - 1;
		my $c = $self->{column} - 1;

		my $scr = $self->{screen};

		if ($c >= 0) {
			$self->{screen}->[$l]->[$_] = undef for (0 .. $c);
		}

		if ($l > 0) {
			$self->{screen}->[$_] = undef for (0 .. $l-1);
		}
	}

	elsif ($n == 2) {
		$self->{screen} = [];
	}
}


sub EL {
	my $self = shift;
}


1;


__END__


=pod

=head1 NAME

Parse::ANSIScreen - Keep track of what would be displayed on a terminal
supporting ANSI escape sequences.


=head1 SYNOPSIS

	my $scr = Parse::ANSIScreen->new();
	my $str = "\e[5;3HAloha\e[3BAn example\e[2B\n";  # \e == ESC

	$scr->parse($str);
	$scr->print_screen();

	my $array_ref = $scr->dump();


=head1 DESCRIPTION

Parse::ANSIScreen provides a way to track the state of textmode screens fed
with strings with ANSI escape sequences.


=head1 METHODS

=over 4

=item new (CSI_regexp)

Constructor. If CSI_regexp is ommited, C<qr/\e[/> will be used.

=item print_screen ()

Print the screen as it would be displayed by a terminal supporting ANSI escape
sequences.

=item dump ()

Returns a two-dimensional array that represents the screen.

=back

=cut
