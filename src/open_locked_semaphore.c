#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <semaphore.h>

int main(int argc, char ** argv){
	if (argc < 2)
		printf("usage : %s <semaphore_name>", argv[0]);
	sem_t * sem = NULL;
	sem = sem_open(argv[1] , O_CREAT, 0666, 1);
	if (sem == SEM_FAILED){
		perror("Error : Can't open nor create the database semaphore");
		exit(EXIT_FAILURE);
	}
	sem_wait(sem);
	return EXIT_SUCCESS;
}
