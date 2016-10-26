function [timeStr, transitionStr, transitionStr2, transition, transition2]=oppositeFlowPumps(transition,maxFlow, noiseStrength)

format bank
noise= randn(1,numel(transition))*noiseStrength;
transition=round((transition+noise)*100)/100
noise= randn(1,numel(transition))*noiseStrength;
transition2= round((maxFlow-transition+noise)*100)/100;
transition(transition<0)=0;
transition2(transition2<0)=0;
transitionStr=getEnterTimesString(transition);

transitionStr2=getEnterTimesString(transition2);
timeStr= getTimes(transition);

end

