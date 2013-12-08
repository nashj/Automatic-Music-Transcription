  % Warning: this is written for Octave and not tested with MATLAB
  % This also uses libsvm. The libsvm I have included has been built for Octave

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

  W = [];
  for i = 1:numel(wavs)
    if (~isempty(wavs{i}))
        
      % Read File
      wavs{i} = strcat('../data/notes/', wavs{i});
      disp(wavs{i});
      [y,fs,bps] = wavread(wavs{i});
      
      % Constant Q Transform
      %[S, f, spec_t] = qgram(y, fs,1); 
      [S, f, spec_t] = spectrogram(y, 2048, 2048-160, 2048, fs);

      % Zero-out spectra with low energy (for noise reduction)
      Sen = sum(abs(S).^2);
      S(:, Sen <  1e-9) = zeros(88,sum(Sen < 1e-9));

      % Average the signal-containing spectra
      Sm = mean(abs(S)');
     
      % Magnitude warping and mean subtraction proposed by Niedermeyer
      g = mean(Sm); % What average should we use (mean? outlier resistant?)
      S_warp = log(1 + (1/g).*Sm);
      y = smooth(S_warp, 9);
      wi = max(0, S_warp - y');
      
      plot(wi);
      drawnow;
      W = [W; wi];
    end
  end
  W = W./(max(max(W)));
  imagesc(W);

%%
  wav_file = '../data/br_im2.wav';
  % Open wav file
  [y,fs,bps] = wavread(wav_file);

  %[S, f, spec_t] = qgram(y, fs,1);
   [S, f, spec_t] = spectrogram(y, 2048, 2048-160, 2048, fs);

 %% 
  % Add the libsvm and midi libraries  
  addpath('../lib/libsvm');
  addpath('../lib/nmf');
 
  magS = abs(S).^2;
  magS = magS ./ (max(max(magS)));

  %[W2, H, iter, ~] = nmf(abs(S), 88, 'verbose',2, 'w_init', W);

  %H = rand(88, length(S));
  %Wt = W';
  bins = size(S,1);
  H = [];
for i = 1:length(magS)
    fprintf('Testing frame: %i\n', i);
    v = magS(:, i);
    h = zeros(88, 1);
    P = [];
    Z = (1:88)';
    
    gradcost = Wt'*(v - Wt*h); % least squares gradient
    skip_grad = 0;
    iters = 0;
    while (~isempty(Z) || any(gradcost(Z) >= 0))
        %fprintf('Norm error %g\n', .5*norm(Wt*h - v)^2);
        %pause
        iters = iters + 1;
        if (iters > 10)
            break;
        end
        if (skip_grad == 0)

            gradcost = Wt'*(v - Wt*h);
            [max_el, ind] = max(gradcost);

            P = [P; ind(1)]; % add
            Z(Z == ind(1)) = []; % remove
            
        end
        skip_grad = 0;

        Wsub = Wt;
        Wsub(:, Z) = zeros(bins , numel(Z));
        %fprintf('Znumel %i\n', numel(Z));

        z = pinv(Wsub)*v;

        if (all(z(P)) >= 0)
            h = z;
            continue;
        end


        skip_grad = 1;
        
        
        neg_ind = find(z < 0);
        [~, ind] = min(h(neg_ind)./(h(neg_ind)-z(neg_ind)));
        alpha = z(neg_ind(ind));
        
        h = h + alpha*(z - h);
        
        P(P == find(h == 0)) = [];
        Z = [Z; find(h == 0)];
        
        
    end
    
    %pause;
    H = [H h];
  
    
    
end