function [smooth_pr] = smooth_hmm(raw_pr, nn, priors_cell, trans_mat_cell, em_mat_cell) 
  %%% HMM Smooth %%%
  smooth_pr = zeros(size(raw_pr));

  for i=1:size(nn,2)
    fprintf('Smoothing note %d\n', i);

    trans_mat_cell{i}
    em_mat_cell{i}
    
    cur_note = nn(i);
    sequence = raw_pr(i,:);  

    sequence(sequence==1) = 2;
    sequence(sequence<=0) = 1;
    states = hmmviterbi(sequence, trans_mat_cell{i}, em_mat_cell{i}); 
    smooth_pr(i,:) = states;
  end
end
