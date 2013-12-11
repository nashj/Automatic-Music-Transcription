  % Warning: this is written for Octave and not tested with MATLAB
  % This also uses libsvm. The libsvm I have included has been built for Octave
  more off;
  fs = 0;
  
  % Get list of training notes
  isOctave = exist('OCTAVE_VERSION') ~= 0;
  if isOctave
         filelist = readdir('../data/notes');
      for i = 1:numel(filelist)
        if (regexp (filelist{i},'^\w+.wav$'))
            wavs{i} = filelist{i};
        end
      end
  else
      filelist = dir('../data/notes');
      for i = 1:numel(filelist)
        if (regexp (filelist(i).name,'^\w+.wav$'))
            wavs{i} = filelist(i).name;
        end
      end
  end

  W = zeros(2049, 88);
  for i = 1:numel(wavs)
    if (~isempty(wavs{i}))
        
      % Read File
      wavs{i} = strcat('../data/notes/', wavs{i});
      disp(wavs{i});
      [y,fs,bps] = wavread(wavs{i});
      y = [zeros(length(y),1); y];
      
      % Constant Q Transform
      %[S, f, spec_t] = qgram(y, fs); 
      [S, f, spec_t] = spectrogram(y, 4096, 4096-160, 4096, fs);
      S = abs(S);
      Sen = (sum(S).^2);
      S(:, Sen < 100) = 0;

      % Average the signal-containing spectra
      Sm = mean(S, 2);
     
      % Magnitude warping and mean subtraction proposed by Niedermeyer
      g = mean(Sm); % What average should we use (mean? outlier resistant?)
      S_warp = log(1 + (1/g).*Sm);
      
      %%y = smooth(S_warp, 9);
      y = filter(ones(9,1)/9, 1, S_warp);
      wi = max(0, S_warp - y);
      
      plot(wi);
      drawnow;
      W(:, i-2) = wi';
    end
  end
 W = abs(W);
 figure; imagesc(W);


%%
  wav_file = '../data/br_im2.wav';
  % Open wav file
  [y,fs,bps] = wavread(wav_file);

  %[Sy, f, spec_t] = qgram(y, fs);
  [Sy, f, spec_t] = spectrogram(y, 4096, 4096-160, 4096, fs);
  
%%
 
magS = abs(Sy);
V = magS;
for i = 1:length(magS)
      Sm = magS(:, i);
     
      % Magnitude warping and mean subtraction proposed by Niedermeyer
      g = mean(Sm); % What average should we use (mean? outlier resistant?)
      S_warp = log(1 + (1/g).*Sm);
      
      %%y = smooth(S_warp, 9);
      y = filter(ones(9,1)/9, 1, S_warp);
      wi = max(0, S_warp - y);
      V(:, i) = wi';
end
V = V(1:1024,:); % Drop upper half freqs
  W = W(1:1024, :);

 %% 
  % Add the libsvm and midi libraries  
  addpath('../lib/nmf');
  addpath('../lib/matlab-midi/src');


  Wt = W';
  bins = size(magS,1);
  H = [];
 H = rand(88, length(V));

 for i=1:200 % Use actual stopping criteria here
     fprintf('Update #%d:\n', i);
     
     % Apply update rule to W and H
     %Wnew = W + (W*H - magS) * H';
     %Hnew = H + W'*(W*H - magS);
     H = H .* ((W'*V) ./ (W'*W*H + 1e-9));
     S_norm = norm(V - W*H, 'fro'); % Shows how close W*H is to the spectrogram
     fprintf('S_norm: %g\n\n', S_norm);
 end
%for i = 1:length(magS)
%for i = 1:2000
%    fprintf('Testing frame: %i\n', i);
%    v = magS(:, i);
%    h = zeros(88, 1);
%    P = [];
%    Z = (1:88)';
%    
%    gradcost = Wt'*(v - Wt*h); % least squares gradient
%    skip_grad = 0;
%    iters = 0;
%    while (~isempty(Z) || any(gradcost(Z) >= 0))
%        %fprintf('Norm error %g\n', .5*norm(Wt*h - v)^2);
%        %pause
%        iters = iters + 1;
%        if (iters > 10)
%            break;
%        end
%        if (skip_grad == 0)
%
%            gradcost = Wt'*(v - Wt*h);
%            [max_el, ind] = max(gradcost);
%
%            P = [P; ind(1)]; % add
%            Z(Z == ind(1)) = []; % remove
%            
%        end
%        skip_grad = 0;
%
%        Wsub = Wt;
%        Wsub(:, Z) = zeros(bins , numel(Z));
%        %fprintf('Znumel %i\n', numel(Z));
%
%        z = pinv(Wsub)*v;
%
%        if (all(z(P)) >= 0)
%            h = z;
%            continue;
%        end
%
%
%        skip_grad = 1;
%        
%        
%        neg_ind = find(z < 0);
%        [~, ind] = min(h(neg_ind)./(h(neg_ind)-z(neg_ind)));
%        alpha = z(neg_ind(ind));
%        
%        h = h + alpha*(z - h);
%        
%        P(P == find(h == 0)) = [];
%        Z = [Z; find(h == 0)];
%        
%        
%    end
%    
%    %pause;
%    H = [H h];
%  
%end


%%
H2 = H;
H3 = zeros(size(H));
% Smoothing
for i = 1:88
    H2(i, :) = medfilt1(H(i,:), 40);
end

% Frame Level Normalization
H3 = H2;
for i = 1:length(H2)
    H3(:,i) = H2(:,i) ./ mean(H2(:,i));
end

%%
% Thresholding

H4 = zeros(size(H));

for i = 1:88

	thresh = std(H3(i,:));

	H4(i, H3(i,:) > thresh ) = 1;

end


imagesc(H4(:, 1:2000));



midi = readmidi('../data/br_im2.mid');
notes = midiInfo(midi,0);
[pr, t, nn] = piano_roll(notes);

pr_norm = zeros(88, length(pr));
pr_norm((nn(1)-20):end-(108-nn(end)), :) = pr(:, 1:length(pr));
[Acc, E_tot, E_sub, E_miss, E_fa, precision, recall, f] = calc_error( pr_norm, H4, 15996 )
%subset = 2000;
%figure; view_piano_roll(t(1:subset),nn,pr(:,1:subset), 'Ground truth');
%%
start = 9000;
stop = 11000;
 subplot 411
imagesc(H(:, start:stop))
title('Raw Note Activity (H)');
subplot 412; 
imagesc(H3(:, start:stop))
title('Smoothed Note Activity (H)');
subplot 413
imagesc(H4(:, start:stop))
title('Threshold Note Activity (H)');
subplot 414
imagesc(pr_norm(:, start:stop))
title('Ground Truth')
