#!/bin/bash
.PHONY: latex

latex:
	pdflatex -shell-escape paper.tex
	bibtex paper
	pdflatex paper.tex
