package Parse::ANSIScreen;

use v5.10;
use strict;
use warnings;

use Carp;


sub new {
	my $class = shift;
	my ($CSI) = @_;

	my %self = {
		CSI     => $CSI // qr/\e]/,
		line    => 1,
		column  => 1,
		screen  => [],
	};

	return bless \%self, $class;
}


sub read {
	my $self = shift;
	my ($fh) = @_;

	defined (my $str = <$fh>) or croak "readline: $!";
	chomp $str;

	my @sequences = split($self->{CSI}, $str);

	foreach (@sequences) {
		 if    (/(\d*)A(.*)/) { $self->CUU($1, $2); }
		 elsif (/(\d*)B(.*)/) { $self->CUD($1, $2); }
		 elsif (/(\d*)C(.*)/) { $self->CUF($1, $2); }
		 elsif (/(\d*)D(.*)/) { $self->CUB($1, $2); }
	}

	return $self->{screen};
}


sub wr_screen {
	# Write a string in our representation of the screen
	my $self = shift;
	my ($str) = @_;

	return unless (defined $str);

	my $l = $self->{line};

	for (split(//, $str)) {
		my $c = $self->{column}++;
		$self->{screen}->[$l]->[$c] = $_;
	}
}

sub CUU {
	# Move cursor up
	my $self = shift;
	my ($n, $str) = @_;

	$self->{line}-- if ($self->{line} > 1);
	$self->wr_screen($str);
}

sub CUD {
	# Move cursor down
	my $self = shift;
	my ($n, $str) = @_;

	$self->{line}++;
	$self->wr_screen($str);
}

sub CUF {
	# Move cursor forward
	my $self = shift;
	my ($n, $str) = @_;

	$self->{column}++;
	$self->wr_screen($str);
}

sub CUB {
	# Move cursor backward
	my $self = shift;
	my ($n, $str) = @_;

	$self->{column}-- if ($self->{column} > 1);
	$self->wr_screen($str);
}
