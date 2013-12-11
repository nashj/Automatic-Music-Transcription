function [pr, nn] = midi_cache(midi_file)
  more off;
  mat_cache = strcat(midi_file, '.cache.mat');
  try 
      load(mat_cache);
      fprintf('Cached MIDI found!\n');
  catch		      
      fprintf('Cached MIDI does not exist. Creating new cache.\n'); 		     
      addpath('../lib/matlab-midi/src');
      midi = readmidi(midi_file);
      notes = midiInfo(midi,0);
      [pr, g, nn] = piano_roll(notes);
      save(mat_cache, 'pr', 'nn');
  end
end