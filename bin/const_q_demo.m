function Q = const_q_demo

more off;

[y,fs,bps] = wavread('../data/br_im2.wav');
length(y)
% Every 10 ms = 160 samples shift
steps = (length(y) - 19856)/160 + 1;
spec = 175;
% spec = 88;
Q = zeros(spec, steps);
step_range = 1:3000;
sparkernel = sparse_kernel(27.5, 4186.01, 24, 16000);

for i=step_range
   fprintf('Iter: %d\n', i);
   %q = const_q(y(1+(i-1)*160:end)', 27.5, 4186.01, 12, 16000);
   q = const_q_fast(y(1+(i-1)*160:end)', sparkernel);
   Q(:,i) = q;
end

Q = abs(Q(:, step_range));
imagesc(Q);
pause

end



