# Dependencies

* Term::ReadKey
* Term::ANSIScreen

# Usage

	perl viewer.pl /path/to/replay

Commands are:
* `j` : go to next turn
* `k` : go to previous turn
* `:` : show the prompt for more complex commands
The prompt accepts these commands:
* `N` : goto turn number N.
* `s N` : slideshow with N turns per second. Any key stops the slideshow.
* `b N` : backward slideshow with N turns per second. Any key stops the slideshow.
