function [T1, T2, T3] = evaluate_full_scenario(trajectories, allocation, missiles, uavs, constraints)
    % Evaluate protection times for all three missiles
    
    protection_times = zeros(1, 3);
    
    for m = 1:3
        if ~isempty(trajectories.groups{m})
            protection_times(m) = trajectories.shields(m);
        else
            protection_times(m) = 0;
        end
    end
    
    T1 = protection_times(1);
    T2 = protection_times(2);
    T3 = protection_times(3);
end