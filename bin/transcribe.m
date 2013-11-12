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

  % Add the libsvm and midi libraries  
  addpath("../lib/libsvm");
  addpath("../lib/matlab-midi/src");

  % Open the MIDI file
  midi = readmidi(midi_file);
  notes = midiInfo(midi,0);
  % T is in increments of 10ms, the same as our STFT'd wav file
  [pr, t, nn] = piano_roll(notes);
  % size(pr,2)
  % sum(pr,2)

  % View piano roll:
  % figure;
  % imagesc(t,nn,pr);
  % axis xy;
  % xlabel('time');
  % pause;

  % This is a way to convert midi to wav, but it wasn't working for me:
  % [y,Fs] = midi2audio(midi);
  % wavwrite(y,Fs,'out.wav');

  % Train 88 SVMs for each piano key
  for i=1:88
      % fprintf('Training SVM %d...\n', i);
  end

end
