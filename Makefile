UNAME := $(shell uname)

SSH_HOST=198.199.100.84
SSH_PORT=22
SSH_USER=serge
SSH_TARGET_DIR=/var/www/sergerey.org/public_html

plain_html:
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
	scp ~/Dropbox/l/lima/paper/final.pdf serge@198.199.100.84:/var/www/sergerey.org/public_html/papers/lima16.pdf


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

upload:
	scp -P $(SSH_PORT) rey_cv.html  $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)/index.html

PY?=python
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

FTP_HOST=localhost
FTP_USER=anonymous
FTP_TARGET_DIR=/

SSH_HOST=198.199.100.84
SSH_PORT=22
SSH_USER=serge
SSH_TARGET_DIR=/var/www/sergerey.org/public_html

S3_BUCKET=my_s3_bucket

CLOUDFILES_USERNAME=my_rackspace_username
CLOUDFILES_API_KEY=my_rackspace_api_key
CLOUDFILES_CONTAINER=my_cloudfiles_container

DROPBOX_DIR=~/Dropbox/Public/

GITHUB_PAGES_BRANCH=gh-pages

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

help:
	@echo 'Makefile for a pelican Web site					'
	@echo '								       '
	@echo 'Usage:								 '
	@echo '   make html			(re)generate the web site	  '
	@echo '   make clean		       remove the generated files	 '
	@echo '   make regenerate		  regenerate files upon modification '
	@echo '   make publish		     generate using production settings '
	@echo '   make serve [PORT=8000]	   serve site at http://localhost:8000'
	@echo '   make devserver [PORT=8000]       start/restart develop_server.sh    '
	@echo '   make stopserver		  stop local server		  '
	@echo '   make ssh_upload		  upload the web site via SSH	'
	@echo '   make rsync_upload		upload the web site via rsync+ssh  '
	@echo '   make dropbox_upload	      upload the web site via Dropbox    '
	@echo '   make ftp_upload		  upload the web site via FTP	'
	@echo '   make s3_upload		   upload the web site via S3	 '
	@echo '   make cf_upload		   upload the web site via Cloud Files'
	@echo '   make github		      upload the web site via gh-pages   '
	@echo '								       '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo '								       '

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	cd $(OUTPUTDIR) && $(PY) -m pelican.server $(PORT)
else
	cd $(OUTPUTDIR) && $(PY) -m pelican.server
endif

devserver:
ifdef PORT
	$(BASEDIR)/develop_server.sh restart $(PORT)
else
	$(BASEDIR)/develop_server.sh restart
endif

stopserver:
	kill -9 `cat pelican.pid`
	kill -9 `cat srv.pid`
	@echo 'Stopped Pelican and SimpleHTTPServer processes running in background.'

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

ssh_upload: publish
	rm -r $(OUTPUTDIR)/drafts
	scp -P $(SSH_PORT) -r $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

rsync_upload: publish
	rm -r $(OUTPUTDIR)/drafts
	cp ~/Dropbox/v/vitae/vitae/rey_cv.pdf $(OUTPUTDIR)/.
	scp ~/Dropbox/l/lima/paper/final.pdf $(INPUTDIR)/pdfs/lima16.pdf
	rsync -e "ssh -p $(SSH_PORT)" -P -rvzc --delete $(OUTPUTDIR)/ $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude


dropbox_upload: publish
	cp -r $(OUTPUTDIR)/* $(DROPBOX_DIR)

ftp_upload: publish
	lftp ftp://$(FTP_USER)@$(FTP_HOST) -e "mirror -R $(OUTPUTDIR) $(FTP_TARGET_DIR) ; quit"

s3_upload: publish
	s3cmd sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --acl-public --delete-removed --guess-mime-type

cf_upload: publish
	cd $(OUTPUTDIR) && swift -v -A https://auth.api.rackspacecloud.com/v1.0 -U $(CLOUDFILES_USERNAME) -K $(CLOUDFILES_API_KEY) upload -c $(CLOUDFILES_CONTAINER) .

github: publish
	ghp-import -b $(GITHUB_PAGES_BRANCH) $(OUTPUTDIR)
	git push origin $(GITHUB_PAGES_BRANCH)

.PHONY: html help clean regenerate serve devserver publish ssh_upload rsync_upload dropbox_upload ftp_upload s3_upload cf_upload github
