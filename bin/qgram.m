function Q = qgram(y, fs, bins_multiplier)
% y is the signal
% fs is the sampling frequency
% bins_multiplier multiples the number of bins per octave. When bins_multiplier=1, bins=12 (which is the number of semitones per octave). It seems like researchers typically choose bins_multiplier=2 for more resolution

if (nargin < 3)
   bins_multiplier = 2;
end

% Flip vector if it's a column vector
if (size(y,2) == 1)
   y = y';
end

% Note: I'm leaving out high frequencies by choosing highest_key = 4186.01, so we might want to raise this to improve classification

% Compute the sparse kernel for the fast constant-q transform
semitones_per_octave = 12;
lowest_key = 27.5;
highest_key = 4186.01;
sparkernel = sparse_kernel(lowest_key, highest_key, semitones_per_octave*bins_multiplier, fs);

% Initialize the Q-gram matrix
spec_bins = size(sparkernel,2);
step_size = .01*fs; % 10 ms
steps = (length(y) - size(sparkernel,1))/step_size + 1;
Q = zeros(spec_bins, steps);

% Compute the constant-q transform at every .01*fs seconds
for i=1:steps
   q = const_q_fast(y(1+(i-1)*step_size:end), sparkernel);
   Q(:,i) = q; 
end

% To plot:
% imagesc(abs(Q));

end