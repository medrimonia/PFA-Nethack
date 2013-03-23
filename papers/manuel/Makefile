manuel.pdf: manuel.dvi
	dvipdf manuel.dvi

manuel.dvi: manuel.tex
	latex manuel.tex && latex manuel.tex

clean:
	@rm -f *~ manuel.aux manuel.log manuel.toc manuel.dvi manuel.pdf
