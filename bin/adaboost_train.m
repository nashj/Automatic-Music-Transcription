function adaboost_train(wav_file, midi_file)
  more off;
  % Wav file, midi file
  fprintf('Reading wav file...\n');
  [y,fs,bps] = wavread(wav_file);	 
  % Compute the STFT on 128ms frames with 10ms hops
  %isOctave = exist('OCTAVE_VERSION') ~= 0;
  %if isOctave
  %  [S, f, spec_t] = specgram(y, 2048, fs, hanning(.128*fs), 2048 - 160); % Needs to be spectrogram in MATLAB  
  %else
  %  [S, f, spec_t] = spectrogram(y, 2048, 2048-160, 2048, fs);
  %end
  % magS = abs(S);

  [magS, f, spec_t] = qgram_cache(wav_file); 

  %addpath('../lib/matlab-midi/src');
  addpath('../lib/GML_AdaBoost_Matlab_Toolbox_0.3/');

  %fprintf('Reading midi file...\n');
  %midi = readmidi(midi_file);
  %notes = midiInfo(midi,0);
  %[pr, t, nn] = piano_roll(notes);

  [pr, nn] = midi_cache(midi_file);
  
  % Train the decision tree on the spectrogram and midi note labels
  % Randomly select 

  subset = 1000;
  view_piano_roll(spec_t(1:subset), nn, pr(:,1:subset), 'MIDI notes');


  num_notes = nn(end)-nn(1)+1;
  
  rlearners_cell = cell(1,num_notes);
  rweights_cell = cell(1,num_notes);

  for i=1:num_notes
      fprintf('Training stumps %d...\n', i);
      note_vec = pr(i,:);
      
      if sum(note_vec) == 0
      	 continue
      end

      % Randomly sample postive examples (<=100)
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

      training_labels = [ones(1,num_examples) -1*ones(1,num_examples)];
      training_input = [pos_examples neg_examples];

      max_iter = 10;
      weak_learner = tree_node_w(1); % pass the number of tree splits to the constructor
      [rlearners, rweights] = RealAdaBoost(weak_learner, training_input, training_labels, max_iter);
      rlearners_cell{i} = rlearners;
      rweights_cell{i} = rweights;
      
      rresult = sign(Classify(rlearners, rweights, training_input));
      
      rresult
      rerror = sum(training_labels ~= rresult) / length(training_labels)
      %rerror 
  end

  estimated_pr = zeros(size(pr,1), size(magS,2));

  save('adaboost_stumps', 'rlearners_cell', 'rweights_cell');
end