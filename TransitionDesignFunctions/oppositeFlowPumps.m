function [timeStr, transitionStr, transitionStr2, transition, transition2]=oppositeFlowPumps(transition,maxFlow)
transition2= maxFlow-transition;
transitionStr=getEnterTimesString(transition);
transitionStr2=getEnterTimesString(transition2);
timeStr= getTimes(transition);

end

