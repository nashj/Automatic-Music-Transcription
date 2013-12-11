
  % Get list of test files
isOctave = exist('OCTAVE_VERSION') ~= 0;
wavs = {};
mids = {}
if isOctave
  wavcount = 1;
  midcount = 1;
  filelist = readdir('../data');
  for i = 1:numel(filelist)
    if (regexp (filelist{i},'.wav$'))
        wavs{wavcount} = strcat('../data/',filelist{i});
        wavcount = wavcount + 1;
    end
    if (regexp (filelist{i},'.mid$'))
        mids{midcount} = strcat('../data/',filelist{i});
        midcount = midcount + 1;
    end
  end
else
  filelist = dir('../data/');
  wavcount = 1;
  midcount = 1;
  for i = 1:numel(filelist)
    if (regexp (filelist(i).name,'.wav$'))
        wavs{wavcount} = strcat('../data/',filelist(i).name);
        wavcount = wavcount + 1;
    end
    if (regexp (filelist(i).name,'.mid$'))
        mids{midcount} = strcat('../data/', filelist(i).name);
        midcount = midcount + 1;
    end
  end
end

% Constant Q %%%%%%%%%%%%%%%%

W = nmf_train(0,0);

Acc_av = 0;
E_tot_av = 0;
E_sub_av = 0;
E_miss_av = 0;
E_fa_av = 0;
precision_av = 0;
recall_av = 0;
f_av = 0;
for i = 1:numel(wavs)
    [ ~, ~, Acc, E_tot, E_sub, E_miss, E_fa, precision, recall, f ] = nmf_transcribe(W, wavs{i}, mids{i}, 0, 0);
    Acc_av = Acc_av + Acc;
    E_tot_av = E_tot_av + E_tot;
    E_sub_av = E_sub_av + E_sub;
    E_miss_av = E_miss_av + E_miss;
    E_fa_av = E_fa_av + E_fa;
    precision_av = precision_av + precision;
    recall_av = recall_av + recall;
    f_av = f_av + f;
end

Acc_av = Acc_av / numel(wavs)
E_tot_av = E_tot_av / numel(wavs)
E_sub_av = E_sub_av / numel(wavs)
E_miss_av = E_miss_av / numel(wavs)
E_fa_av = E_fa_av / numel(wavs)
precision_av = precision_av / numel(wavs)
recall_av = recall_av / numel(wavs)
f_av = f_av / numel(wavs)

pause;

