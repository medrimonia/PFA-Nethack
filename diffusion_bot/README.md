DIFFUSION_BOT
=============

This folder contains everything needed to build the diffusion bot. The bot

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
java -Djava.library.path=/usr/lib/libmatthew-java -jar diffusion_bot/Bot.jar
```
It's possible to run directly the bot with a one line command
```
java -Djava.library.path=`locate libunix-java.so | xargs dirname` -jar diffusion_bot/Bot.jar 
```

## Bot main line
The two key-words of this bots are propagation and scoring.
Basically, each turn, the bot will compute a list of action with an associated
score for each one, then the bot will choose and apply the action with the
highest associated score.

### Scoring
Each square has an associated score, calculated as the sum of all subscores,
each one depending on a specific feature of the game.
Here are some subscores :
* DownStairScore _Score of applying the downstair action on this square_
* SearchScore _Score of performing a search on the square_
* ForceScore _Score of trying to force the square_
Obviously, some scores are positive only for some types of squares.

An entire module is devoted to scoring, the policy adopted for the score is that
all the intern score are in [0,1] and then a parameter is set, giving a value to
eachScore.

Ex : Square [3,4] has a downStairScore of 0,5 but downstair value is 5000, then
     getDownStairValue will return 2500

With these kind of scoring, it's easy to "forbid" or to "force" an action
without getting to deep into scoring module.

A script allowing to list all those constants is provided (bot_details.sh).

### Propagation
Once all values are computed, propagation starts, the main idea about it is that
when a square has a high score, it'll propagate this value to all it's
neighboors, lowering it with a cost for each move.

Example:

4|0|0|6        4|4|5|6
-------        -------
0|@|2|1  --->  3|@|5|5
-------        -------
3|0|1|2        3|4|4|4

The bot will then move east or north-east (Cost might be parametred)

### Lazy mechanism
In order to avoid spending useless calculs. The bot is using a lazy mechanism,
square's value are only propagated if there has been some changes. When adding
new internScores, a developer must ensure that changing it's value will
propagate the scores before choosing next action.

## Debug
Swapping the value of 'activated' in src/util/Logger.java allows to enable or
disable debug output. This is typically used to debug the bot (when enabled) or
to increase performance (when disabled).

## Unitary tests
Some tests had been created at the beginning, but the protocol has changed since
and these tests aren't working anymore, they should be removed once the project
is clean.