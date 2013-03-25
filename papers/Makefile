MANUAL=manuel/manuel.pdf
REPORT=rapport/rapport.pdf

all: ${MANUAL} ${REPORT}

manual: ${MANUAL}

report: ${REPORT}

%.pdf: %.tex
	pdflatex $^ $@
	pdflatex $^ $@
	@rm -f *~ *.aux *.log *.toc *.dvi

clean:
	@rm -f ${MANUAL} ${REPORT}
