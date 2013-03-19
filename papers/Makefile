MANUAL=manuel/manuel.pdf
REPORT=rapport/rapport.pdf

all: ${MANUAL} ${REPORT}

manual: ${MANUAL}

report: ${REPORT}

%.pdf: %.dvi
	dvipdf $^ $@ & dvipdf $^ $@
	@rm -f *~ *.aux *.log *.toc *.dvi

%.dvi: %.tex
	latex $^ & latex $^
	@cp *.dvi $@

clean:
	@rm -f ${MANUAL} ${REPORT}
