function [priors_cell, trans_mat_cell, em_mat_cell] = estimate_hmm(raw_pr, nn, true_pr)
  %%% Estimate HMM %%%
  % Run a hidden markov model over the piano roll for smoothing the raw log posterior probabilities
  % Estimation of priors and transition matrix can be done using MIDI files (ground truth)
  % Estimation of emission matrix should be done using predict_label from SVM
  
  % 1 is off
  % 2 is on

  num_frames = size(raw_pr, 2);
  num_notes = size(nn,2);

  trans_mat_cell = cell(1,num_notes);
  em_mat_cell = cell(1,num_notes);
  priors_cell = cell(1,num_notes);

  % Estimate a HMM for each note
  for i=1:size(nn,2)
    fprintf('Estimating HMM %d\n', i);
    cur_note = nn(i);

    % If cur_note is not actually played in song, skip it
    %if (isempty(find(notes_list == cur_note, 1)))
    %    continue;
    %end

    % Estimate prior
    prior_on = sum(true_pr(i,:)) / num_frames;
    prior_off = 1 - prior_on;

    % Estimate transition matrix
    trans_mat = zeros(2,2);
    prev_frame = 0;
    for j=1:num_frames
    	cur_frame = true_pr(i,j);
	trans_mat(prev_frame+1, cur_frame+1) = trans_mat(prev_frame+1, cur_frame+1) + 1;
	prev_frame = cur_frame;
    end
    trans_mat = trans_mat ./ num_frames;

    % Estimate emission matrix
    em_mat = zeros(2,2);
    for j=1:num_frames
    	% 1 gr, 1 emission

	em_mat(true_pr(i,j)+1, raw_pr(i,j)+1) = em_mat(true_pr(i,j)+1, raw_pr(i,j)+1) + 1; 
    end
    em_mat =  em_mat ./ num_frames;

    % Save results to cells
    trans_mat_cell{i} = trans_mat;
    em_mat_cell{i} = em_mat;
    priors_cell{i} = [prior_off prior_on];
    trans_mat
    em_mat
    [prior_ff prior on]
    
  end

end

