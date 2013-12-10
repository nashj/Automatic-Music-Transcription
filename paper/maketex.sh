#!/bin/bash
pdflatex -shell-escape paper.tex
bibtex paper
pdflatex paper.tex
pdflatex paper.tex
