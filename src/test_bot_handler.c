#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "bot_handler.h"

void test_botcmd2nhcmd(void) {
	char * nhcmd = botcmd_to_nhcmd("MOVE SOUTH_WEST");
	assert(0 == strcmp(nhcmd, "b"));
	free(nhcmd);

	nhcmd = botcmd_to_nhcmd("MOVE NORTH");
	assert(0 == strcmp(nhcmd, "k"));
	free(nhcmd);

	nhcmd = botcmd_to_nhcmd("MOVE EAST");
	assert(0 == strcmp(nhcmd, "l"));
	free(nhcmd);

	nhcmd = botcmd_to_nhcmd("OPEN SOUTH");
	assert(0 == strcmp(nhcmd, "oj"));
	free(nhcmd);

	nhcmd = botcmd_to_nhcmd("FORCE WEST");
	assert(0 == strcmp(nhcmd, "\4h"));
	free(nhcmd);
}

int
main (void) {
	test_botcmd2nhcmd();

	printf("Every test is OK.\n");

	return 0;
}
