NAME=text
PRINT=gv
#PRINT=lpr -Pc

REFS=References_all.bib
REPL=find_replace.pl
ARGS="-halt-on-error"

all: text.tex
	TEXINPUTS=:.:./style/agutex latex $(ARGS) text.tex
	bibtex text
	TEXINPUTS=:.:./style/agutex latex $(ARGS) text.tex
	bibtex text
	dvipdf text.dvi

reply:
	latex reply.tex
	dvips -z -f -Ppdf -Pcmz < reply.dvi > reply.ps
	ps2pdf reply.ps
	gs -q -sPAPERSIZE=letter -sDEVICE=pdfwrite \
	      -sOutputFile=editor.pdf \
	      -dFirstPage=1 -dLastPage=1 -dNOPAUSE -dBATCH  \
	      reply.pdf
	gs -q -sPAPERSIZE=letter -sDEVICE=pdfwrite \
	      -sOutputFile=reply_to_reviewers.pdf \
	      -dFirstPage=2 -dLastPage=10 -dNOPAUSE -dBATCH  \
	      reply.pdf

table:
	latex table1.tex
	dvips -z -f -Ppdf -Pcmz < table1.dvi > table1.ps
	ps2pdf table1.ps

submit:
	cp ${NAME}.tex ${NAME}_submit.tex
	${REPL} \
	".*documentclass\[jgrga\]\{agu2001\}" \
	"\documentclass[draft,jgrga]{agu2001}" \
	${NAME}_submit.tex 1
	${REPL} \
	".*\\includegraphics" \
	"\includegraphics" \
	${NAME}_submit.tex 1
	make all "NAME=correcting_submit"
	gs -q -sPAPERSIZE=letter -sDEVICE=pdfwrite \
	      -sOutputFile=submit_body.pdf \
	      -dFirstPage=1 -dLastPage=19 -dNOPAUSE -dBATCH  \
	      ${NAME}_submit.pdf
	gs -q -sPAPERSIZE=letter -sDEVICE=pdfwrite \
	      -sOutputFile=submit_figs.pdf \
	      -dFirstPage=6 -dLastPage=11 -dNOPAUSE -dBATCH  \
	      ${NAME}_figs.pdf
	gs -q -sPAPERSIZE=letter -sDEVICE=pdfwrite \
	      -sOutputFile=submit.pdf \
	      -dNOPAUSE -dBATCH  \
	      submit_body.pdf submit_figs.pdf table1.pdf

figs:
	cp ${NAME}.tex ${NAME}_figs.tex
	${REPL} \
	".*documentclass\[draft\,jgrga\]\{agu2001\}" \
	"\documentclass[jgrga]{agu2001}" \
	${NAME}_figs.tex 1
	${REPL} \
	".*\\includegraphics" \
	"\includegraphics" \
	${NAME}_figs.tex 1
	make all "NAME=correcting_figs"
	gs -q -sPAPERSIZE=letter -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
	      -sOutputFile=all.pdf correcting_figs.pdf table1.pdf

${NAME}.dvi: ${NAME}.tex $(REFS)
	TEXINPUTS=:.:./style/agutex latex ${NAME}.tex
	bibtex ${NAME}
	TEXINPUTS=:.:./style/agutex latex ${NAME}.tex
	bibtex ${NAME}
	TEXINPUTS=:.:./style/agutex latex ${NAME}.tex

${NAME}.ps: ${NAME}.dvi
	dvips -t letter -z -f -Ppdf -Pcmz < ${NAME}.dvi > ${NAME}.ps

${NAME}.pdf: ${NAME}.ps
	ps2pdf ${NAME}.ps

print:
	${PRINT} ./semiannual.ps
	${PRINT} ./table1.ps
	${PRINT} ./table2-4.ps
	${PRINT} ../figures/doy_plot_tseries.eps
	${PRINT} ../figures/doy_plot_stack_GS.eps
	${PRINT} ../figures/doy_plot_stack_GS_b08.eps
	${PRINT} ../figures/slope_am.eps
	${PRINT} ../figures/slope_all_1.eps
	${PRINT} ../figures/slope_all_2.eps
	${PRINT} ../figures/epoch_am.eps
	${PRINT} ../figures/epoch_all_1.eps
	${PRINT} ../figures/epoch_all_2.eps
	${PRINT} ../figures/irf_ab_am.eps
	${PRINT} ../figures/irf_all_1.eps
	${PRINT} ../figures/irf_all_2.eps

clean:
	- rm -f *~ *.dvi *.aux *.log *.ps *.bbl *.blg *.tmp

distclean: clean
	- rm -f *.pdf

