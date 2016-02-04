function [ramp, times]=generateNoisyRamp(start, finish, duration,strength)
%%duration is in minutes. strength is the noise scaling factor from a
%%standard normal distribution value to add to the sequence. values between
%%0.03 and 0.06 recomended

ramp=linspace(start, finish, duration);
noiseVector= randn(1, numel(ramp))*strength
ramp=ramp+noiseVector
times=getTimes(noiseVector);

end