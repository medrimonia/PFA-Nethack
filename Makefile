SUBDIRS = \
	documentation \
	src \
	
all: doxygen

doxygen:
	make -C documentation

clean:
	@rm -f $~;
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE clean;  \
	done


