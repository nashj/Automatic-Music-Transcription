function [estimated_pr, pr] = transcribe(wav_file, midi_file)
  % Warning: this is written for Octave and not tested with MATLAB
  % This also uses libsvm. The libsvm I have included has been built for Octave

  % ***Note to self***
  % I'm worried that the wav file and midi file are not aligned properly

  % Setup
  % 0. Generate 16KHz wave file from midi

  % Training steps
  % 1. Compute STFT of wave file
  % 2. Normalize the STFT
  % 3. Train SVMs matched to the midi file

  % Testing steps
  % 4. Run SVM on new wave file
  % 5. Run HMM on SVM piano roll output 

  more off;

  % Open wav file
  [y,fs,bps] = wavread(wav_file);
  % length(y)
  % fs
  % .128*fs
  %.01*fs
  % Compute the STFT on 128ms frames with 10ms hops
  %[S, f, spec_t] = specgram(y, 2048, fs, hanning(.128*fs), 2048 - 160); % Needs to be spectrogram in MATLAB  
  [S, f, spec_t] = spectrogram(y, 2048, 2048-160, 2048, fs);
  
  size(S) 
  spec_t(end)
  % pause
  % Compute the FFT magnitudes
  magS = abs(S);

  % Normalize, whiten the FFT magnitudes (to-do)
    
  % Add the libsvm and midi libraries  
  addpath('../lib/libsvm');
  addpath('../lib/matlab-midi/src');

  % Open the MIDI file
  midi = readmidi(midi_file);
  notes = midiInfo(midi,0);
  % T is in increments of 10ms, the same as our STFT'd wav file
  [pr, t, nn] = piano_roll(notes);
  size(pr)
  % pause
  % sum(pr,2)

  view_piano_roll(t,nn,pr)

  % This is a way to convert midi to wav, but it wasn't working for me:
  % [y,Fs] = midi2audio(midi);
  % wavwrite(y,Fs,'out.wav');
  
  % Train 88 SVMs for each piano key
  % For reasons I do not understand, the note number goes from 20s to 90s
  num_notes = nn(end)-nn(1);
  svm_models = cell(num_notes);
  for i=1:num_notes
      fprintf('Training SVM %d...\n', i);
      note_vec = pr(i,:);
      
      if sum(note_vec) == 0
      	 continue
      end

      % Randomly sample postive examples (<=50)
      pos = find(note_vec == 1);

      num_examples = 0;
      if length(pos) < 50
      	 num_examples = length(pos);
      else
	 num_examples = 50;
         pos = pos(randperm(length(pos)));
      end

      pos = pos(1:num_examples);
      pos_examples = magS(:,pos);

      % Randomly sample same number of negative examples
      neg = find(note_vec == 0);
      neg = neg(randperm(length(neg)));
      neg = neg(1:num_examples);
      neg_examples = magS(:,neg);
      
      midi_note = nn(i);
      if (midi_note >= 21 && midi_note <= 83) %0-2K
          pos_examples = pos_examples(1:256, :);
          neg_examples = neg_examples(1:256, :);
      elseif (midi_note > 83 && midi_note <= 95) %1K-3K
          pos_examples = pos_examples(128:384, :);
          neg_examples = neg_examples(128:384, :);              
      else                                          %2K-4K
          pos_examples = pos_examples(256:512, :);
          neg_examples = neg_examples(256:512, :);   
      end

      % Train SVM on these samples
      training_labels = [ones(1,num_examples) -1*ones(1,num_examples)]';
      training_input = [pos_examples neg_examples]';
      training_input = training_input(:, :);
      svm_models{i} = svmtrain(training_labels, training_input, '-s 1 -t 2 -c 0.1 -q'); 
  end

  % Just to test this for now, rerun these svms on the wave file and generate a piano roll
  % estimated_pr = zeros(size(pr));
  estimated_pr = zeros(size(pr,1), length(spec_t));

  % pr time length should equal S time length, but they're off by a few hundred samples, so I'm suspicious that timidity is adding extra time somewhere

  subset = 2000;
  for i=1:subset % size(S,2)
      fprintf('Predicting time step %d of %d\n', i,subset);
      for j=1:num_notes
        if isempty(svm_models{j})
	     % We had no notes to train on 
	     continue
        end
      	  % Evaluate note SVM on STFT 
	  [predict_label, accuracy, dec] = svmpredict(rand(1), magS(:,i)', svm_models{j},'-q');
	  estimated_pr(j,i) = dec; % Converts -1 -> 0, 1 -> 1
      end
  end

  view_piano_roll(spec_t(1:subset), nn, estimated_pr(:,1:subset));

  % Run a hidden markov model over the piano roll for smoothing the raw log posterior probabilities
  

end



function [out] = view_piano_roll(t, nn, pr)
  % View piano roll
  % t is an array of times, usually in increments of .01s
  % nn are the note numbers 
  % pr is the piano roll binary matrix
  
  figure;
  imagesc(t,nn,pr);
  axis xy;
  xlabel('Time');
  ylabel('Notes');
  pause;
  out = 0;
end