SUBDIRS =   \
	manuel  \
	rapport \

all: 
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE;        \
	done

clean:
	@rm -f *~;
	@for FILE in $(SUBDIRS); do \
	  $(MAKE) -C $$FILE clean;  \
	done

mrproper:
	@rm -f *~;
	@for FILE in $(SUBDIRS); do   \
	  $(MAKE) -C $$FILE mrproper; \
	done
