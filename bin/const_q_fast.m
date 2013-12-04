function cq = const_q_fast(x, sparKernel)    % x must be a row vector
  cq = fft(x,size(sparKernel,1)) * sparKernel;   
end

% Note: sparKernel takes a couple seconds to compute, but only needs to be computed once. This is why it's added in separately
% See const_q_demo for an example
