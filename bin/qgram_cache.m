function [absQ, f, spec_t] = qgram_cache(wav_file)
  % Note: I'm returning absQ instead of Q. We never use Q and absQ saves space
  more off;
  mat_cache = strcat(wav_file, '.cache');
  try 
    load(mat_cache);
    fprintf('Cached qgram found!\n');
  catch 
    fprintf('Cached qgram does not exist. Creating new qgram\n');
    [y,fs,g] = wavread(wav_file);
    [Q, f, spec_t] = qgram(y,fs,2);
    absQ = abs(Q);
    save(mat_cache, 'absQ', 'f', 'spec_t');
  end
end
