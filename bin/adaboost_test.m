function adaboost_test(wav_file, midi_file)

  [magS, f, spec_t] = qgram_cache(wav_file); 
  [pr, nn] = midi_cache(midi_file);
  load('adaboost_stumps');
  num_notes = nn(end)-nn(1)+1;

  subset = 3000;
  view_piano_roll(spec_t(1:subset), nn, pr(:,1:subset), 'MIDI notes');
  
  estimated_pr = zeros(size(pr,1),subset);
  % Predict
  for j=1:subset
    j
    for i=1:num_notes
      if sum(pr(i,:)) == 0
      	 continue
      end

      rresult = sign(Classify(rlearners_cell{i}, rweights_cell{i}, magS(:,j)));
      if rresult < 0
      	 rresult = 0;
      end
      estimated_pr(i,j) = rresult;
    end
  end

  view_piano_roll(spec_t(1:subset), nn, estimated_pr(:,1:subset), 'AdaBoost output');

  save('adaboostout', 'estimated_pr');  

  % Smooth output
  fprintf('Smoothing output\n');
  [priors_cell, trans_mat_cell, em_mat_cell] = estimate_hmm(estimated_pr(:,1:subset), nn, pr(:,1:subset));
  [smooth_pr] = smooth_hmm(estimated_pr, nn, priors_cell, trans_mat_cell, em_mat_cell);   

  save('smoothies', 'smooth_pr');  
  view_piano_roll(spec_t(1:subset), nn, smooth_pr(:,1:subset), 'AdaBoost smoothed output');

end