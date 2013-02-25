CC=gcc

CFLAGS= -g -Wall -Wextra #std=c99 is forbidden because nethack doesn't use it
LFLAGS= -lsqlite3 -pthread

HEADER_DIR= ../include

TESTS=

# N

all: test

%.o: %.c
	${CC} ${CFLAGS} -I ${HEADER_DIR} -o $@ -c $<

# MODULE SPECIFIC RULES

# BOT HANDLER

test: test_bot_handler.o bot_handler.o
	${CC} -o $@ $^ ${LFLAGS}

bot_handler.o: bot_handler.c bot_handler.h
	${CC} ${CFLAGS} -o $@ -c $< 

test_bot_handler.o: test_bot_handler.c bot_handler.h
	${CC} ${CFLAGS} -o $@ -c $< 

run_test: test
	@./test

run_valgrind: test
	valgrind ./test

# GAME STATISTICS

game_statistics.o: ${HEADER_DIR}/game_statistics.h

# DATABASE MANAGER

TESTS+= test_db

test_db: test_database.o database_manager.o game_result.o game_statistics.o
	${CC} -o $@ $^ ${LFLAGS}

database_manager.o: ${HEADER_DIR}/database_manager.h \
										${HEADER_DIR}/game_result.h      \
                    seek_secret.def	                 \
                    door_discovery.def

game_result.o: ${HEADER_DIR}/game_result.h           \
							 ${HEADER_DIR}/game_statistics.h       \
               seek_secret.def

clean:
	@rm -f *~ *.o test
