function [out] = transcribe(wav_file, midi_file)
  % Warning: this is written for Octave and not tested with MATLAB
  % This also uses libsvm. The libsvm I have included has been built for Octave

  % Setup
  % 0. Generate 16KHz wave file from midi

  % Training steps
  % 1. Compute STFT of wave file
  % 2. Normalize the STFT
  % 3. Train SVMs matched to the midi file

  % Testing steps
  % 4. Run SVM on new wave file
  % 5. Run HMM on SVM piano roll output 

  % Open wav file
  [y,fs,bps] = wavread(wav_file);

  % Compute the STFT on 128ms frames with 10ms hops
  [S, f, t] = specgram(y, ceil(.128*fs), fs, [], ceil(.01*fs)); % Needs to be spectrogram in MATLAB  
  % Compute the FFT magnitudes
  magS = abs(S);
  % Normalize, whiten the FFT magnitudes (to-do)
  
  % Open the MIDI file
  
  # Train 88 SVMs for each piano key
  addpath("../lib/libsvm");
  addpath("../lib/matlab-midi/src")
  
  for i=1:88
      fprintf('Training SVM %d...\n', i);
  end

end
