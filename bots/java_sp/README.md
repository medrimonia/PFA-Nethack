JAVA STARTER PACKAGE
====================

This folder contains everything needed to build the java starter package. The
code is designed to provide a soft basis, allowing developers to start
the programmation of a smarter bot easily.

## Building the bot
A script is present to ensure easy compilation, it uses the file in unix.jar to
build a complete Bot.jar archive containing everything needed.
WARNING : It is still needed to install the package libunixsocket-java (also
called libmatthew-java on some systems) to run the bot properly.

## Running the bot
On some computers, simply using java -jar Bot.jar might not work because of the
use of libunix-java.
_Thanks to David Renault for pointing this problem and giving a solution_
Typically this will result in the following error :
```
java.lang.UnsatisfiedLinkError: no unix-java in java.library.path
        at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1738)
        at java.lang.Runtime.loadLibrary0(Runtime.java:823)
        at java.lang.System.loadLibrary(System.java:1028)
        at cx.ath.matthew.unix.UnixSocket.<clinit>(UnixSocket.java:33)
        at bot.InputOutputUnit.<init>(InputOutputUnit.java:29)
        at bot.Bot.<init>(Bot.java:31)
        at LaunchBot.main(LaunchBot.java:12)
```
If this happens, the solution is to find the location of libunix-java.so
```
>>> locate libunix-java.so
<LIB_PATH>/libunix-java.so
```
And then it's possible to run the bot with
```
java -Djava.library.path=/usr/lib/libmatthew-java -jar java_starter_package/Bot.jar
```
It's possible to run directly the bot with a one line command
```
java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar java_starter_package/Bot.jar 
```

## Bot main line
The bot main algorithm is to compute all the possible actions and to choose
randomly one among them (some actions might still be considered as valid even if
that's not true because some unusual cases aren't treated). The choices made
by the bot are not really smart, but since they aren't deterministic, the bot
can't enter in an endless loop and performs better than a lot of bugged
implementations. It can serve as a reference point, because if a bot performs
worse than this starter package, it has probably major issues.

## Debug
Swapping the value of 'activated' in src/util/Logger.java allows to enable or
disable debug output. This is typically used to debug the bot (when enabled) or
to increase performance (when disabled).

## Unitary tests
Some tests had been created at the beginning, but the protocol has changed since
and these tests aren't working anymore, they should be removed once the project
is clean.