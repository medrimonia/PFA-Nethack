# SRC README

The description of each module (including tests etc should be done here)


## BOT HANDLER

This module is used to translate orders between Nethack's kernel language and
bots' language. It also provides a point of connection for bots.

You can run a test with:
$ make run_test

and a valgrind test with:
$ make run_valgrind

## DATABASE MANAGER

This module require the installation of the sqlite3 headers and library.
Both are contained in the package: libsqlite3-dev