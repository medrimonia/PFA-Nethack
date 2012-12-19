# Setup 
In order to use this program, you need to install the following modules from
the CPAN:
* Term::VT102
* Term::ReadKey
* IO::Pty::Easy

Installation can be done using the 'cpan -i module' command after you've
properly configured your cpan.

Alternatively, you can install cpanminus (a zero-conf CPAN client) and run
'cpanm module'. See https://metacpan.org/module/cpanm for more details.

In order to install these modules without root privileges, you can use
local::lib which is likely to be already installed in most linux systems. See https://metacpan.org/module/local::lib.


# Usage

'interface.pl' launches the nethack binary given as a parameter, or the
system's default 'nethack' binary (typically, in your PATH) if no parameter is
specified. You can then play the game as you normally would, with the usual
keybindings, in the same terminal that you lanched interface.pl from. The
program accepts multiple bot connections on TCP port 4242.
