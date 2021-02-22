SRCDIR=src
COMPRESSED=dists
TEXFILE=debian-book
SOURCES=$(wildcard *.tex *.sty)
TSTAMP=$(shell date +"%Y-%m-%d")

help:
	@echo ""
	@echo Available BUILD Targets:
	@echo " - pdf               builds $(TEXFILE).pdf in $(SRCDIR)/ directory "
	@echo " - html              builds $(TEXFILE).html - all in one html file - in $(SRCDIR)/ directory"
	@echo " - htmlsplit         builds splitted html files in htmlsplit/ directory"
	@echo " - clean             clean stuff in $(SRCDIR)/ directory"	
	@echo ""
	@echo Available DIST Targets:
	@echo " - dists-clean       clean stuff in $(COMPRESSED)/ directory"
	@echo " - dist-src          builds LaTeX source distribution in $(COMPRESSED)/ directory"
	@echo " - dist-pdf          builds PDF   output distribution in $(COMPRESSED)/ directory"
	@echo " - dist-htmlsplit    builds HTML  output distribution - splitted html files in $(COMPRESSED)/ directory"
	@echo " - dist-html         builds HTML  output distribution - all in one html file in $(COMPRESSED)/ directory"
	@echo " - dists             builds all available dists in $(COMPRESSED)/ directory"
	@echo ""
	@echo " - all                              "
	@echo " - help              print this help"
	@echo ""

pdf: $(TEXFILE).pdf

html: $(TEXFILE).html

htmlsplit: htmlsplit/$(TEXFILE).html

%.pdf: %.tex
	-@pdflatex $(TEXFILE)
	-@pdflatex $(TEXFILE)
# comment the row below if you want to see *.aux and *.toc files
	-rm *.aux *.toc 

$(TEXFILE).pdf: $(SOURCES)

$(TEXFILE).html: $(SOURCES)
	-mkdir temphtml
	latex2html \
		-split 0 \
		-html_version 4.0 \
		-unsegment \
		-no_auto_link \
		-no_navigation \
		-dir temphtml \
		$(TEXFILE).tex
	cat temphtml/$(TEXFILE).html \
		| sed -e "s/charset=iso-8859-1/charset=windows-1251/" > $(TEXFILE).html
	@cp temphtml/$(TEXFILE).css .
	@echo "BODY { background-color: white; margin: 4em }" >> $(TEXFILE).css
	@echo "IMG { margin: 1em }" >> $(TEXFILE).css
	echo "@media screen { PRE { background: #bbddff } }" >> $(TEXFILE).css
	-rm -rf temphtml

htmlsplit/$(TEXFILE).html: $(SOURCES)
	-mkdir htmlsplit
	latex2html \
		-html_version 4.0 \
		-scalable_fonts \
		-local_icons \
		-iso_language BG \
		-dir htmlsplit \
		-no_auto_navigation \
		-split 4 \
		$(TEXFILE).tex
	for i in htmlsplit/*.html; do \
	cat "$$i" | sed \
	-e "s/charset=iso-8859-1/charset=windows-1251/"  > "$$i.new" \
	-e 's/Next/Напред/g' \
	-e 's/Previous/Назад/g' \
	-e 's/Contents/Съдържание/g' ; \
	mv "$$i".new "$$i" ; \
	done ; \
	echo "BODY { background-color: white; margin: 4em }" >> htmlsplit/$(TEXFILE).css ; \
	echo "IMG { margin: 1em }" >> htmlsplit/$(TEXFILE).css
	echo "@media screen { PRE { background: #bbddff } }" >> htmlsplit/$(TEXFILE).css
	cp -r images htmlsplit

clean:
	-@rm -rf *.idx *.log *.toc *.dvi *.out *.pdf *.html *.css `find -name "*.aux"` htmlsplit 2>&1 &>/dev/null; echo done >/dev/null

dists-clean:
	-@cd ..  ; rm -r $(COMPRESSED)/$(TEXFILE)*.bz2  &>/dev/null; echo done >/dev/null

dist-src: clean
	cd ..; tar --use-compress-program bzip2 -cf $(COMPRESSED)/$(TEXFILE)-$(TSTAMP)-latex.tar.bz2 $(SRCDIR)

dist-pdf: $(TEXFILE).pdf
	cp    $(TEXFILE).pdf $(TEXFILE)-$(TSTAMP).pdf
	-bzip2 $(TEXFILE)-$(TSTAMP).pdf
	mv    $(TEXFILE)-$(TSTAMP).pdf.bz2 ../$(COMPRESSED)

dist-htmlsplit: htmlsplit
	tar --use-compress-program bzip2 -cf ../$(COMPRESSED)/$(TEXFILE)-$(TSTAMP)-htmlsplit.tar.bz2 htmlsplit

dist-html: html
	tar --use-compress-program bzip2 -cf ../$(COMPRESSED)/$(TEXFILE)-$(TSTAMP)-html.tar.bz2 $(TEXFILE).html images $(TEXFILE).css 

dists: dist-pdf dist-htmlsplit dist-html dist-src

all: dists-clean dists pdf html htmlsplit 
