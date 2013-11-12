#!/bin/bash
# Syntax:
# ./timmy song.mid
# outputs song.wav (keeps the original name)

output=${1%.*}".wav"
timidity $1 -OwM -o $output

