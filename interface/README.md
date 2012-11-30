# Setup

In order to use this program, you need to install the following modules from
the CPAN:
* Term::VT102
* IO::Pty::Easy
* Term::ReadKey

Installation can be done using the 'cpan -i module' command after you've
properly configured your cpan.

Alternatively, you can install cpanminus (a zero-conf CPAN client) and run
'cpanm module'. See https://metacpan.org/module/cpanm for more details.

In order to install these modules without root privileges, you can use
local::lib. See https://metacpan.org/module/local::lib.


# Usage

The program interface.pl spawns the NetHack game found in your PATH. It
accepts connections on port 9999 (likely to change in the near future) using
UDP. The dummy-client.pl program connects to this port on localhost, reads
input from the keyboard and sends them to the interface.
