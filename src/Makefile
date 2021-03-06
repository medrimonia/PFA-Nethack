CC=gcc

#std=c99 is forbidden because nethack doesn't use it
CFLAGS= -g -Wall -Wextra -DNO_NETHACK_ACCESS
LFLAGS= -lsqlite3 -pthread -lrt

HEADER_DIR= ../include

.PHONY: all run_test run_valgrind clean

all: test_db open_locked_semaphore

run_test: all
	@./test_db

run_valgrind: all
	valgrind ./test_db

%.o: %.c
	${CC} ${CFLAGS} -I ${HEADER_DIR} -o $@ -c $<

# MODULE SPECIFIC RULES

# GAME STATISTICS

game_statistics.o: ${HEADER_DIR}/game_statistics.h

# DATABASE MANAGER

TABLE_FILES=$(wildcard *.c)

database_manager.o: ${HEADER_DIR}/database_manager.h \
                    ${HEADER_DIR}/game_result.h      \
                    ${TABLE_FILES}

game_result.o: ${HEADER_DIR}/game_result.h           \
               ${HEADER_DIR}/game_statistics.h       \
               ${TABLE_FILES}

open_locked_semaphore: open_locked_semaphore.o
	${CC} -o $@ $^ ${LFLAGS}

test_db: test_database.o database_manager.o game_result.o game_statistics.o
	${CC} -o $@ $^ ${LFLAGS}

clean:
	@rm -f *~ *.o test_db open_locked_semaphore
