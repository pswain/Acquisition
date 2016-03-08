function [flowStr, timeStr, flowVec]=replicateTransition(transition, times)
%%this function concatenates a transition with itself a number of times 
flowVec=repmat(transition,1,times);

flowStr= getEnterTimesString(flowVec);
timeStr= getTimes(flowVec);

end
