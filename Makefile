.DEFAULT_GOAL = all
.PHONY: readme js package all

readme:
	rm -f man/figures/README* ; Rscript -e "rmarkdown::render('README.Rmd', output_file='README.md', output_format='github_document')"

js:
	cd build; ./buildjs.sh ; ./copyjs.sh ; 

package:
	 cd ..; R CMD build uaparserjs ; R CMD check --as-cran `ls -t uaparserjs_*.tar.gz | head -1` ; 

install: 
	cd .. ; R CMD INSTALL ./`ls -t uaparserjs_*.tar.gz | head -1`
	 
all: js package install readme package
