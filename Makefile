SUBDIRS = \
	documentation \
	src \
	
all: PFA-Nethack bots

PFA-Nethack:
	@./nh-setup.sh

bots:
	make -C bots

run:
	@./scripts/game_runner.sh

doxygen:
	make -C documentation

clean:
	@rm -f *~;
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE clean;  \
	done


