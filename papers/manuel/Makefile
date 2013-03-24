manuel.pdf: manuel.dvi
	dvipdf manuel.dvi
	@make clean

manuel.dvi: manuel.tex
	latex manuel.tex && latex manuel.tex

clean:
	@rm -f *~ *.aux *.log *.toc *.dvi *.out

mrproper: clean
	@rm -f manuel.pdf
