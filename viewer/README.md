# Dependencies

* Term::ReadKey
* Term::ANSIScreen
	
A script called `setup.pl` can install them automatically. Installation can be done manually with `cpan -i module` for each dependency.

# Usage

First, make sure to enable replay recording by setting NH\_MM\_REPLAY environment variable to 1. This will create a `replay` file in the `nethackdir` directory. To view a game played by the bot, run:

	perl viewer.pl /path/to/replay

Commands are:
* `j` : go to next turn
* `k` : go to previous turn
* `:` : show the prompt for more complex commands

The prompt accepts these commands:
* `N` : goto turn number N.
* `s N` : slideshow with N turns per second. Any key stops the slideshow.
* `b N` : backward slideshow with N turns per second. Any key stops the slideshow.
