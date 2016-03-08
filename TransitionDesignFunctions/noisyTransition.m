function [timeStr, transitionStr, flowVec]=noisyTransition(transition, noiseStrength)

flowVec= transition+ randn(1, numel(transition))*noiseStrength;

timeStr=getTimes(flowVec);
transitionStr=getEnterTimesString(flowVec);

end