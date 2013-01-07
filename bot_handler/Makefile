CC=gcc

CFLAGS=-Wall -Wextra
LFLAGS=

all: test

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

clean:
	@rm -f *~ *.o test
