#!/bin/bash
# Syntax:
# ./timmy song.mid
# outputs song.wav (keeps the original name)

# Note on the 16k sampling rate:
# The SVM paper uses an 8k sampling rate, but
# I noticed a significant quality drop at 8k, 
# whereas 16k seems to preserve the original quality
# Note, too, that the highest key on the piano is 4186Hz,
# which means 8k is insufficient, but this note also contains 
# harmonics, so I think 16k is a good sampling rate to capture
# these overtones.

output=${1%.*}".wav"
timidity $1 -OwM -o $output -s 16k

