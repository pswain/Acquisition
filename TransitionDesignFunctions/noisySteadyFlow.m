function [flowStr, timeStr, flowVec]=noisySteadyFlow(flow, duration, noiseStrength)

flowVec= repmat(flow, 1,duration);
noise= randn(1,numel(flowVec))*noiseStrength;

flowVec=flowVec+noise;
flowStr=getEnterTimesString(flowVec);
timeStr=getTimes(flowVec);

end

