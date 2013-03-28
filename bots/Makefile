SUBDIRS =$(shell find . -mindepth 2 -maxdepth 2 -name Makefile -printf '%h\n')

all: 
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE;        \
	done

clean:
	@find . -name '*~' -delete -o -name '*.pyc' -delete
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE clean;  \
	done
