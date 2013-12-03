function view_piano_roll(t, nn, pr, title_str)
  % View piano roll
  % t is an array of times, usually in increments of .01s
  % nn are the note numbers 
  % pr is the piano roll binary matrix
  
  figure;
  imagesc(t,nn,pr);
  axis xy;
  title(title_str);
  xlabel('Time');
  ylabel('Notes');
  % pause;
  drawnow
end
