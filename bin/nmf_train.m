function [ W ] = nmf_train(use_qgram, draw_plots)


  % This also uses libsvm. The libsvm I have included has been built for Octave
  more off;
if (nargin < 1)
    use_qgram = 0;
    draw_plots = 0;
end

if (nargin == 1)
    draw_plots = 0;
end
    
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
  count = 1;
  for i = 1:numel(filelist)
    if (regexp (filelist(i).name,'.wav$'))
        wavs{count} = filelist(i).name;
        count = count + 1;
    end
  end
end

bins = 2049;
if (use_qgram)
    bins = 175;
end
W = zeros(bins, 88);
for i = 1:numel(wavs)
    if (~isempty(wavs{i}))
        
      % Read File
      wavs{i} = strcat('../data/notes/', wavs{i});
      disp(wavs{i});      % Constant Q Transform
      if (use_qgram)
        [S, f, spec_t] = qgram_cache(wavs{i}); 
      else
        [y,fs,bps] = wavread(wavs{i});
        y = [zeros(length(y),1); y];
        [S, f, spec_t] = spectrogram(y, 4096, 4096-160, 4096, fs);    
      end

      % Crop low energy spectra
      S = abs(S);
      Sen = (sum(S).^2);
      thresh = 100;
      if (use_qgram)
          thresh = 1e-5;
      end
          
      S(:, Sen < thresh) = 0;

      % Average the signal-containing spectra
      Sm = mean(S, 2);

      % Magnitude warping and mean subtraction proposed by Niedermeyer
      g = mean(Sm); % What average should we use (mean? outlier resistant?)
      S_warp = log(1 + (1/g).*Sm);

      %%y = smooth(S_warp, 9);
      y = filter(ones(9,1)/9, 1, S_warp);
      wi = max(0, S_warp - y);

      if (draw_plots)
          plot(wi);
          drawnow;
      end
      W(:, i) = Sm';
    end
end

W = abs(W);
if (draw_plots)
    figure; imagesc(W);
end

end

