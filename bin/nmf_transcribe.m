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
      [S, f, spec_t] = qgram(y, fs,1); 

      % Zero-out spectra with low energy (for noise reduction)
      Sen = sum(abs(S).^2);
      S(:, Sen <  1e-9) = zeros(88,sum(Sen < 1e-9));

      % Average the signal-containing spectra
      Sm = mean(abs(S)');
     
      % Magnitude warping and mean subtraction proposed by Neidermeyer
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

  [S, f, spec_t] = qgram(y, fs,1); 

    
  % Add the libsvm and midi libraries  
  addpath('../lib/libsvm');
  addpath('../lib/nmf');
pause;
  [W2, H, iter, ~] = nmf(abs(S), 88, 'verbose',2, 'type', 'sparse', 'w_init', W);

