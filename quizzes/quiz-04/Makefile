.PHONY: all student sol clean

all: student sol

student:
	@sed 's/^\\soltrue/% \\soltrue/' quiz.tex > .student.tex
	pdflatex -interaction=nonstopmode -jobname=quiz .student.tex >/dev/null
	pdflatex -interaction=nonstopmode -jobname=quiz .student.tex >/dev/null
	@rm -f .student.tex quiz.aux quiz.log quiz.out

sol:
	pdflatex -interaction=nonstopmode -jobname=quiz-sol quiz.tex >/dev/null
	pdflatex -interaction=nonstopmode -jobname=quiz-sol quiz.tex >/dev/null
	@rm -f quiz-sol.aux quiz-sol.log quiz-sol.out

clean:
	rm -f *.aux *.log *.out *.pdf .student.tex
