use 5.014;
use strict;
use warnings;

use IO::Pty::Easy;
use Term::ReadKey;

ReadMode(4);

my $pty = IO::Pty::Easy->new();
$pty->autoflush(1);
$pty->spawn("nethack -X | tee log.txt");

defined (my $pid = fork()) or die "fork: $!";

# parrent - show the game
if ($pid) {
    my $map = [];

    my ($l, $c) = (0, 0);
    while ($pty->is_active()) {
        my $nh_msg = $pty->read();

        foreach (split /\e/, $nh_msg) {
            # catch cursor positionning
            if (/^\[(\d+);(\d+)[Hf](.*)/) {
                ($l, $c, my $s) = ($1, $2, $3);
                $map->[$l]->[$c++] = $_ for (split //, $s);
            }

            # move cursor to the top left
            elsif (/^\[[Hf](.*)/) {
                ($l, $c, my $s) = (0, 0, $1);
                $map->[$l]->[$c++] = $_ for (split //, $s);
            }

            # clear screen
            elsif (/^\[2J/) { ($l, $c) = (0, 0); $map = []; }

            # erase line
            #elsif (/^\[K/) { $map->[$l] = []; }

            # move cursor
            elsif (/^\[(\d*)A/) { $l -= ($1 || 1); }
            elsif (/^\[(\d*)B/) { $l += ($1 || 1); }
            elsif (/^\[(\d*)C/) { $c += ($1 || 1); }
            elsif (/^\[(\d*)D/) { $c -= ($1 || 1); }

            # uncaught cases
            elsif (/^\[/) {
                print "UNCAUGHT: $_\n";
            }

            else {
                foreach my $s (split //) {
                    $map->[$l]->[$c++] = $s;
                }
            }
        }

        print_map($map);
    }
}

# child - catch key press events
lse {
    while ($pty->is_active()) {
        my $key = ReadKey(0);
        $pty->write($key);
    }
}

$pty->close();


# End of main program

sub print_map {
    my ($map_ref) = @_;
    foreach my $line (@$map_ref) {
        foreach (@$line) { defined $_ ? print : print "_"; }
        print "\n";
    }
}
