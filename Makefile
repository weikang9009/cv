html:
	cat head.md appointments.md pubs.md > p1.md
	cat p1.md presentations.md grants.md teaching.md > p2.md
	cat p2.md service.md > full.md
	rm p1.md p2.md
	pandoc full.md -o rey_cv.html


latex:
	cat appointments.md pubs.md > p1.md
	cat p1.md presentations.md grants.md teaching.md > p2.md
	cat p2.md service.md > full.md
	rm p1.md p2.md
	pandoc full.md -o full.tex
	rm full.md
	cat head.tex full.tex tail.tex > rey_cv.tex
	xelatex rey_cv.tex
	rm full.tex

clean:
	rm *.aux *.log *.bbl *.blg



