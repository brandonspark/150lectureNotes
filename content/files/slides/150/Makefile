# =============================================================================
# 15-150 final exams
#
#   make            build both exams, blank + solutions (4 PDFs)
#   make final      just the real final (both versions)
#   make practice   just the practice final (both versions)
#   make blank      only the student-facing versions
#   make sol        only the solution keys
#   make stats      questions / parts / points / pages
#   make breakdown  per-question part counts and points
#   make clean      remove build artifacts (keeps PDFs)
#   make distclean  also remove PDFs
#
# Output:
#   exam_final.pdf         exam_final_sol.pdf
#   exam_practice.pdf      exam_practice_sol.pdf
#
# Each exam is an \input list assembled from q/*.tex and draft_*.tex. Solutions
# are controlled by \blankversion, which q/preamble.tex checks when choosing
# the documentclass options. pdflatex runs twice so point totals resolve.
# =============================================================================

LATEX      := pdflatex
LATEXFLAGS := -interaction=nonstopmode -halt-on-error

EXAMS := exam_final exam_practice
BLANK := $(addsuffix .pdf,$(EXAMS))
SOL   := $(addsuffix _sol.pdf,$(EXAMS))

FRAGMENTS := $(wildcard q/*.tex) $(wildcard q/items/*.tex) $(wildcard draft_*.tex)

.PHONY: all blank sol final practice stats breakdown deps clean distclean

all: blank sol
	@$(MAKE) --no-print-directory warn-untracked

blank: $(BLANK)
sol:   $(SOL)

final:    exam_final.pdf    exam_final_sol.pdf
practice: exam_practice.pdf exam_practice_sol.pdf

# --- student-facing (no solutions) -------------------------------------------
# built under a temp jobname so the _sol .aux files don't collide
%.pdf: %.tex $(FRAGMENTS)
	@echo "==> $* (blank)"
	@$(LATEX) $(LATEXFLAGS) -jobname=$*_blank "\def\blankversion{}\input{$<}" > $*_blank.build.log 2>&1 || \
	  { echo "FAILED:"; grep -E '^!|^l\.[0-9]' $*_blank.build.log | head -20; exit 1; }
	@$(LATEX) $(LATEXFLAGS) -jobname=$*_blank "\def\blankversion{}\input{$<}" > $*_blank.build.log 2>&1
	@mv $*_blank.pdf $@
	@grep -hE 'This exam contains|This exam has a total of [0-9]+ points' $*_blank.build.log | sed 's/^/    /'

# --- solution key ------------------------------------------------------------
%_sol.pdf: %.tex $(FRAGMENTS)
	@echo "==> $* (solutions)"
	@$(LATEX) $(LATEXFLAGS) -jobname=$*_sol $< > $*_sol.build.log 2>&1 || \
	  { echo "FAILED:"; grep -E '^!|^l\.[0-9]' $*_sol.build.log | head -20; exit 1; }
	@$(LATEX) $(LATEXFLAGS) -jobname=$*_sol $< > $*_sol.build.log 2>&1

stats: $(BLANK)
	@printf "%-16s %-11s %-8s %-9s %-7s %s\n" EXAM QUESTIONS PARTS POINTS "PAGES" "PAGES(sol)"
	@for e in $(EXAMS); do \
	  q=$$(grep -oE 'contains [0-9]+ questions' $$e\_blank.build.log | grep -oE '[0-9]+'); \
	  p=$$(grep -oE 'with [0-9]+ parts'        $$e\_blank.build.log | grep -oE '[0-9]+'); \
	  s=$$(grep -oE 'total of [0-9]+ points'   $$e\_blank.build.log | grep -oE '[0-9]+' | head -1); \
	  g=$$(pdfinfo $$e.pdf 2>/dev/null | awk '/^Pages/{print $$2}'); \
	  gs=$$(pdfinfo $$e\_sol.pdf 2>/dev/null | awk '/^Pages/{print $$2}'); \
	  printf "%-16s %-11s %-8s %-9s %-7s %s\n" $$e "$$q" "$$p" "$$s" "$$g" "$${gs:--}"; \
	done

# The old m23 exams (final.tex, practice_final.tex) are self-contained and are
# NOT built here -- the exams this Makefile builds are exam_final.tex and
# exam_practice.tex, assembled from q/ and draft_*. The names are close enough
# to open the wrong one by accident, so say something when they drift.
.PHONY: warn-untracked
warn-untracked:
	@for f in final.tex practice_final.tex; do \
	  [ -f "$$f" ] || continue; \
	  if [ -n "$$(find $$f -newer exam_final.pdf 2>/dev/null)" ]; then \
	    echo "  note: $$f was edited but is not built by this Makefile"; \
	    echo "        (did you mean exam_$${f%.tex}.tex?)" | sed 's/exam_practice_final/exam_practice/'; \
	  fi; \
	done

# What does make actually watch for each exam?
deps:
	@for e in $(EXAMS); do \
	  echo "=== $$e.tex inputs ==="; \
	  grep -oE '\\input\{[^}]*\}' $$e.tex | sed 's/\\input{//;s/}//' | sed 's/^/  /'; \
	done
	@echo "=== all files in FRAGMENTS (prerequisites) ==="
	@for f in $(FRAGMENTS); do echo "  $$f"; done

breakdown:
	@for e in $(EXAMS); do \
	  echo "=== $$e ==="; \
	  grep -oE '\\input\{[^}]*\}' $$e.tex | sed 's/\\input{//;s/}//' \
	    | grep -vE 'preamble|appendix' | while read f; do \
	      [ -f "$$f" ] || continue; \
	      t=$$(grep -oE '\\titledquestion\{[^}]*\}' "$$f" 2>/dev/null | head -1 | sed 's/.*{//;s/}//'); \
	      [ -z "$$t" ] && t="(item) $$(basename $$f .tex)"; \
	      v=$$(grep -oE '^ *\\part\[[0-9]+\]' "$$f" | grep -oE '[0-9]+' | tr '\n' ' '); \
	      s=$$(echo $$v | tr ' ' '+' | sed 's/+$$//' | bc 2>/dev/null); \
	      printf "  %-28s %-18s = %s\n" "$$t" "[$$(echo $$v | sed 's/ $$//')]" "$$s"; \
	    done; \
	done

clean:
	@rm -f *.aux *.log *.out *.build.log *.toc *.nav *.snm *.vrb test_blank.*
	@echo "cleaned build artifacts"

distclean: clean
	@rm -f $(BLANK) $(SOL)
	@echo "removed PDFs"
