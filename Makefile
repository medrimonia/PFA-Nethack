SUBDIRS = documentation \
		  src           \
		  bots          \

.PHONY: all PFA-Nethack bots run doxygen clean 

all: PFA-Nethack bots

PFA-Nethack:
	@./nh-setup.sh

bots:
	make -C bots

run:
	@./scripts/run_bot.sh

play:
	@NH_MM_TIMEOUT=-1
	@./nethack-3.4.3/nethack 2> /tmp/nh_log&
	@perl bots/dummy-client.pl 2> /tmp/bot_log

doxygen:
	make -C documentation

clean:
	@rm -f *~;
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE clean;  \
	done


