# Setup 
In order to use this program, you need to install the following modules from
the CPAN:
* Term::VT102
* Term::ReadKey
* IO::Pty::Easy

The 'cpan' script is part of the Perl standard distribution. It uses tools available on the user's computer to automatically download, unpack, compile, test, and install modules and their dependencies after a very short and almost fully automated configuration process. The first time cpan is run, it will ask a few questions to configure itself and the 'o conf init' command from the cpan shell may be used to reconfigure it if necessary. On most recent Linux distribution, cpan is installed along with local::lib which allows installation of modules without root privileges. See https://metacpan.org/module/local::lib for further information.

Installation of the above mentioned modules can be done using the `setup.pl` script or manualy using the 'cpan -i module\_name' command after you have properly configured your cpan. 


# Usage

'interface.pl' launches the nethack binary given as a parameter, or the system's default 'nethack' binary (typically, in your PATH) if no parameter is specified. You can then play the game as you normally would, with the usual key bindings, in the same terminal that you launched interface.pl from. The program accepts multiple bot connections on TCP port 4242.

# Notes

This program makes NetHack believe the terminal size is 24x160 to prevent the menu and the map to overlap. This means that if your terminal window is smaller, lines will be wrapped and the map will appear to have empty lines in the middle which are in fact the lines used by the (possibly empty) menu.
