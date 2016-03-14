function timeString=getTimes(vec)
%%this function obtains the time string associated to a transition vector.
%%for example,  if the transition is 0.4,0.5, 1 then the time string with
%%start 1 would be 1,2,3. the function assumes each transition starts at 1



timeString=strjoin(strsplit( num2str(1:1:numel(vec)), ' '),',');

end