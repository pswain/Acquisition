function [enterTimesStr, timeStr, finalvec]=mergeTransitions(varargin)
finalvec=[];
for k=1:nargin
    finalvec= horzcat(finalvec, varargin{k});
end

timeStr=getTimes(finalvec);
enterTimesStr=getEnterTimesString(finalvec)

end


    