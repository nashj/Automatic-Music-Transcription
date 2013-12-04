function cq = const_q(x, minFreq, maxFreq, bins, fs)
  Q= 1/(2^(1/bins)-1);
  K = ceil(bins*log2(maxFreq/minFreq));
  cq = zeros(1,K);
  for k=1:K
    fk = minFreq*2^((k-1)/bins);
    N = round(Q*fs/fk);
    cq(k) = x(1:N) * (hamming(N) .* exp(-2*pi*i*Q*(0:N-1)'/N))/N;
  end
end
