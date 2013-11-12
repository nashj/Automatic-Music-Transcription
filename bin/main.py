#!/usr/bin/env python
import sys
import wave
import numpy
import scipy
from scipy.io import wavfile

def stft(x, fs, frame_time, hop_time):
    frame_samples = int(frame_time*fs)
    hop_samples = int(hop_time*fs)
    w = scipy.hamming(frame_samples)
    X = scipy.array([ scipy.fft(w*x[i:i+frame_samples]) 
                     for i in range(0, len(x)-frame_samples, hop_samples)])
    return X

def main():
    # Expects sys.argv[1] (first argument) to be a wav file
    # Based on the file name, it will search for a similarly named midi file
    
    try:
        w = wavfile.read(sys.argv[1])
    except:
        print "Unable to read the wave file"
        sys.exit(1)
    # Frames are 128ms long
    # Hops are 10ms 
    st = stft(w[1], w[0], .128, .01)
    print st
    

if __name__ == "__main__":
    main()


