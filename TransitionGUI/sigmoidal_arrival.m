function step_values=sigmoidal_arrival(start_value, finish, a,c, number)
    if isempty(number)
        number=50;
    end
normalized_transition= normalized_sigmoidal(number, a,c)


scale= finish-start_value
step_values= start_value+scale*normalized_transition