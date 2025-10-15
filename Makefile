# LaTeX Makefile for Tesina LCC Maglione
# Author: Generated for tesina-lcc project
# Main document: Tesina_LCC_Maglione.tex

# Variables
MAIN = Tesina_LCC_Maglione
TEX_FILES = $(wildcard *.tex) $(wildcard Chapters/*.tex) $(wildcard Matter/*.tex) $(wildcard Metadata/*.tex) $(wildcard Chapters/Appendices/*.tex) $(wildcard Chapters/Annexes/*.tex)
BIB_FILES = $(wildcard Bibliography/*.bib)
CLS_FILES = $(wildcard *.cls)
STY_FILES = $(wildcard Configurations/*.sty)

# LaTeX compiler options
LATEX = xelatex
LATEX_FLAGS = -interaction=nonstopmode -shell-escape -file-line-error
BIBTEX = bibtex
MAKEINDEX = makeglossaries

# Output directory (optional, uncomment if you want output in a separate directory)
# OUTDIR = build
# LATEX_FLAGS += -output-directory=$(OUTDIR)

# Main target
.PHONY: all
all: $(MAIN).pdf

# Main PDF compilation rule
$(MAIN).pdf: $(TEX_FILES) $(BIB_FILES) $(CLS_FILES) $(STY_FILES)
	@echo "Starting LaTeX compilation..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "Running bibtex..."
	-$(BIBTEX) $(MAIN)
	@echo "Processing glossaries and acronyms..."
	-$(MAKEINDEX) $(MAIN)
	@echo "Second LaTeX pass..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "Final LaTeX pass..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "PDF compilation complete: $(MAIN).pdf"

# Quick compile (single pass, useful for draft mode)
.PHONY: quick
quick:
	@echo "Quick compilation (single pass)..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex

# Alternative compilation with pdflatex (without custom fonts)
.PHONY: pdflatex
pdflatex:
	@echo "Compiling with pdflatex (custom fonts disabled)..."
	@echo "WARNING: This may not work if fontspec is required by the class file."
	pdflatex $(LATEX_FLAGS) $(MAIN).tex
	-$(BIBTEX) $(MAIN)
	-$(MAKEINDEX) $(MAIN)
	pdflatex $(LATEX_FLAGS) $(MAIN).tex
	pdflatex $(LATEX_FLAGS) $(MAIN).tex

# Draft mode (working docstage)
.PHONY: draft
draft:
	@echo "Compiling in draft mode..."
	sed -i.bak 's/docstage=final/docstage=working/' $(MAIN).tex
	$(MAKE) all
	mv $(MAIN).tex.bak $(MAIN).tex

# Final mode
.PHONY: final
final:
	@echo "Compiling in final mode..."
	sed -i.bak 's/docstage=working/docstage=final/' $(MAIN).tex
	$(MAKE) all
	mv $(MAIN).tex.bak $(MAIN).tex

# Clean auxiliary files
.PHONY: clean
clean:
	@echo "Cleaning auxiliary files..."
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fdb_latexmk *.fls
	rm -f *.nav *.snm *.vrb *.synctex.gz *.run.xml *.bcf *.idx *.ind *.ilg
	rm -f *.glo *.gls *.glg *.acn *.acr *.alg *.glsdefs *.ist *.xdy
	rm -f *.figlist *.makefile *.fls_latexmk *.listing
	rm -f *~ *.backup *.bak
	find . -name "*.auxlock" -delete 2>/dev/null || true
	find . -name "_minted-*" -type d -exec rm -rf {} + 2>/dev/null || true

# Deep clean (removes PDF as well)
.PHONY: distclean
distclean: clean
	@echo "Removing PDF output..."
	rm -f $(MAIN).pdf

# Force rebuild
.PHONY: rebuild
rebuild: distclean all

# View PDF (opens with default PDF viewer)
.PHONY: view
view: $(MAIN).pdf
	@echo "Opening PDF..."
	@if command -v xdg-open > /dev/null; then \
		xdg-open $(MAIN).pdf; \
	elif command -v evince > /dev/null; then \
		evince $(MAIN).pdf &; \
	elif command -v okular > /dev/null; then \
		okular $(MAIN).pdf &; \
	elif command -v zathura > /dev/null; then \
		zathura $(MAIN).pdf &; \
	else \
		echo "No PDF viewer found. Please install evince, okular, zathura, or another PDF viewer."; \
	fi

# Watch mode (recompile on file changes) - requires inotify-tools
.PHONY: watch
watch:
	@echo "Watching for changes... Press Ctrl+C to stop."
	@if command -v inotifywait > /dev/null; then \
		while true; do \
			inotifywait -e modify $(TEX_FILES) $(BIB_FILES) $(CLS_FILES) $(STY_FILES) 2>/dev/null && \
			$(MAKE) quick || true; \
		done \
	else \
		echo "inotifywait not found. Please install inotify-tools package."; \
		echo "On Fedora: sudo dnf install inotify-tools"; \
		echo "On Ubuntu/Debian: sudo apt install inotify-tools"; \
	fi

# Check LaTeX installation and required packages
.PHONY: check
check:
	@echo "Checking LaTeX installation..."
	@command -v $(LATEX) >/dev/null 2>&1 || { echo "xelatex not found. Please install TeX Live or MiKTeX."; exit 1; }
	@command -v $(BIBTEX) >/dev/null 2>&1 || { echo "bibtex not found. Please install TeX Live or MiKTeX."; exit 1; }
	@command -v $(MAKEINDEX) >/dev/null 2>&1 || { echo "makeglossaries not found. Please install TeX Live or MiKTeX."; exit 1; }
	@echo "LaTeX tools found successfully."
	@echo "Checking for Python (required for minted)..."
	@command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || { echo "Python not found. Required for minted package."; exit 1; }
	@echo "Python found."
	@echo "All dependencies satisfied."

# Install required packages (Fedora)
.PHONY: install-deps
install-deps:
	@echo "Installing LaTeX dependencies (Fedora)..."
	sudo dnf update
	sudo dnf install texlive-scheme-full python3-pygments inotify-tools

# Install required packages (Ubuntu/Debian) - alternative target
.PHONY: install-deps-debian
install-deps-debian:
	@echo "Installing LaTeX dependencies (Ubuntu/Debian)..."
	sudo apt update
	sudo apt install texlive-full python3-pygments inotify-tools

# Show help
.PHONY: help
help:
	@echo "Tesina LCC Maglione Makefile - Available targets:"
	@echo ""
	@echo "  all         - Compile the complete document with XeLaTeX (default)"
	@echo "  quick       - Quick compilation (single pass, for drafts)"
	@echo "  pdflatex    - Alternative compilation with pdfLaTeX (no custom fonts)"
	@echo "  draft       - Compile in draft/working mode"
	@echo "  final       - Compile in final mode"
	@echo "  clean       - Remove auxiliary files"
	@echo "  distclean   - Remove all generated files (including PDF)"
	@echo "  rebuild     - Clean and rebuild everything"
	@echo "  view        - Open the PDF with default viewer"
	@echo "  watch       - Watch for changes and auto-compile"
	@echo "  check       - Check if all required tools are installed"
	@echo "  install-deps- Install LaTeX dependencies (Fedora)"
	@echo "  install-deps-debian - Install LaTeX dependencies (Ubuntu/Debian)"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make          # Compile the document"
	@echo "  make clean    # Clean auxiliary files"
	@echo "  make view     # Compile and view"
	@echo "  make watch    # Auto-compile on changes"

# Default target when no arguments provided
.DEFAULT_GOAL := all
