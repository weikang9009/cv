all: html latex doc readme blog

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

doc: 
	make html
	pandoc full.md -o rey_cv.docx
	rm full.md

readme:
	make html
	cp full.md readme.md
	rm full.md

blog:
	cat pubs.head pubs.md > ~/Dropbox/web/sergerey/content/pages/pubs.md
	cat talks.head presentations.md > ~/Dropbox/web/sergerey/content/pages/talks.md
