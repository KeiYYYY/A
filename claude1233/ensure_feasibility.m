function X_valid = ensure_feasibility(X, uav_id, constraints)
    % Ensure solution satisfies all constraints
    
    % Extract deployment times for this UAV
    deploy_indices = find_deployment_indices(X, uav_id);
    deploy_times = X(deploy_indices);
    
    % Fix timing constraints (minimum 1s between deployments)
    if length(deploy_times) > 1
        sorted_times = sort(deploy_times);
        for i = 2:length(sorted_times)
            if sorted_times(i) - sorted_times(i-1) < constraints.min_interval
                sorted_times(i) = sorted_times(i-1) + constraints.min_interval + 0.1*rand();
            end
        end
        X(deploy_indices) = sorted_times;
    end
    
    % Ensure all times are within bounds
    X(deploy_indices) = max(0, min(15, X(deploy_indices)));
    
    % Check velocity constraints
    v_indices = find_velocity_indices(X, uav_id);
    if ~isempty(v_indices)
        X(v_indices(1)) = max(constraints.v_min, min(constraints.v_max, X(v_indices(1))));
        X(v_indices(2)) = mod(X(v_indices(2)), 2*pi);  % Wrap angle to [0, 2π]
    end
    
    X_valid = X;
end