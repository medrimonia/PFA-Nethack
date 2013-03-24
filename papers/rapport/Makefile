all: rapport.tex
	pdflatex $^ && pdflatex $^
	@make clean

clean:
	@rm -f *~ *.aux *.log *.toc *.dvi *.out

mrproper: clean
	@rm -f rapport.pdf
