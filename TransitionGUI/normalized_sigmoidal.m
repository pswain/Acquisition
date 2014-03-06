function [sigm_transition]=normalized_sigmoidal(size,order,constant)
if isempty(constant)
    constant=10;
end

for j=0:size
y=j+1;

    sigm_transition(y)= 1/ (1+ exp(-order*(j-constant)));
%sigm_transition(y)=(j*exp(order))/((constant+exp(order)) + j*exp(order))
    
end


