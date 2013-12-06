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
      wavs{i} = strcat('../data/notes/', wavs{i});
      disp(wavs{i});
      [y,fs,bps] = wavread(wavs{i});
      [S, f, spec_t] = qgram(y, fs,1); 

      Sen = abs(sum(S));
      S(:, Sen <  0.0000001) = zeros(88,sum(Sen < 0.0000001));

      Sm = abs(S(:,30))';
      %Sm2 = sm;
      %g = mean(S(:, j));
      %Sm2 = log(1 + (1/g).*

      plot(Sm);
      drawnow;
      W = [W; Sm];
    end
  end

  imagesc(W);

    pause;
  num_bins = 176;
% 
% for i = 1:numel(wavs)
%   if (wavs{i} = [])
%   disp(wavs{i});
% end

    pause;

  more off;
  wav_file = '../data/br_im2.wav';
  % Open wav file
  [y,fs,bps] = wavread(wav_file);
  % length(y)
  % fs
  % .128*fs
  %.01*fs
  % Compute the STFT on 128ms frames with 10ms hops
  isOctave = exist('OCTAVE_VERSION') ~= 0;
  if isOctave
    [S, f, spec_t] = specgram(y, 2048, fs, hanning(.128*fs), 2048 - 160); % Needs to be spectrogram in MATLAB  
  else
    [S, f, spec_t] = spectrogram(y, 2048, 2048-160, 2048, fs);
  end

  size(S) 
  spec_t(end)
  % pause
  % Compute the FFT magnitudes
  magS = abs(S);

  % Normalize, whiten the FFT magnitudes (to-do)
    
  % Add the libsvm and midi libraries  
  addpath('../lib/libsvm');
  addpath('../lib/nmf');

  [W, H, iter, ~] = nmf(magS, 88, 'verbose',2, 'type', 'sparse');

