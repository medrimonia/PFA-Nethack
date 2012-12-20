# Setup 
In order to use this program, you need to install the following modules from
the CPAN:
* Term::VT102
* Term::ReadKey
* IO::Pty::Easy

The 'cpan' script is part of the Perl standard distribution. It uses tools available on the user's computer to automatically download, unpack, compile, test, and install modules and their dependancies after a very short and almost fully automated configuration process. The first time cpan is run, it will ask a few questions to configure itself and the 'o conf init' command from the cpan shell may be used to reconfigure it if necessary. On most recent linux distribution, cpan is installed allong with local::lib which allows installation of modules whithout root priviledges. See https://metacpan.org/module/local::lib for further information.

Installation of the above mentioned modules can be done using the 'cpan -i module\_name' command after you have properly configured your cpan. 


# Usage

'interface.pl' launches the nethack binary given as a parameter, or the system's default 'nethack' binary (typically, in your PATH) if no parameter is specified. You can then play the game as you normally would, with the usual keybindings, in the same terminal that you lanched interface.pl from. The program accepts multiple bot connections on TCP port 4242.
