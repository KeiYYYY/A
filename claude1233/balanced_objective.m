function fitness = balanced_objective(T_vec, weights)
    % Multi-objective fitness function
    % T_vec = [T1, T2, T3] - protection times for each missile
    
    T1 = T_vec(1); T2 = T_vec(2); T3 = T_vec(3);
    
    % Component 1: Total protection
    total_protection = T1 + T2 + T3;
    
    % Component 2: Fairness using harmonic mean
    % Add small epsilon to avoid division by zero
    epsilon = 0.1;
    harmonic_mean = 3 / (1/(T1+epsilon) + 1/(T2+epsilon) + 1/(T3+epsilon));
    
    % Component 3: Minimum threshold satisfaction
    min_threshold = 3.0;  % Minimum acceptable protection
    threshold_penalty = sum(max(0, min_threshold - T_vec).^2);
    
    % Weighted combination
    fitness = weights.alpha * total_protection + ...
              weights.beta * harmonic_mean - ...
              weights.gamma * threshold_penalty;
end