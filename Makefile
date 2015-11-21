UNAME := $(shell uname)

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
	cat head.tex full.tex tail.tex > rey_cv.tex
	xelatex rey_cv.tex
	rm full.tex *.log *.aux 

latex_linux:
	cat appointments.md pubs.md > p1.md
	cat p1.md presentations.md grants.md teaching.md > p2.md
	cat p2.md service.md > full.md
	rm p1.md p2.md
	pandoc -N full.md -o full.tex
	sed s/section{/section\*{/ <full.tex >tmp
	mv tmp full.tex
	cat head_linux.tex full.tex tail.tex > rey_cv.tex
	sed 's/\\textasciitilde{}/\\~/g' < rey_cv.tex > tmp
	mv tmp rey_cv.tex
	pdflatex rey_cv.tex
	rm full.tex *.log *.aux 
	scp rey_cv.pdf serge@198.199.100.84:/var/www/sergerey.org/public_html/.

doc: 
	make html
	pandoc full.md -o rey_cv.docx
	rm full.md

readme:
	make html
	cp full.md readme.md
	rm full.md

blog:
	cat pubs.head pubs.md > ~/Dropbox/w/web/sergerey/content/pages/pubs.md
	cat pubs.head pubs.md > ~/Dropbox/w/web/sjsrey.github.io.pelican/content/pages/pubs.md
	cat talks.head presentations.md > ~/Dropbox/w/web/sergerey/content/pages/talks.md
