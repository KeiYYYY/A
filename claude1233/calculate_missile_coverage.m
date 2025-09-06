function coverage_time = calculate_missile_coverage(x, group, missile, uavs, constraints)
    % Calculate total coverage time for a specific missile
    
    dt = 0.01;  % Time step
    max_time = 100;  % Maximum simulation time
    t_blocked = zeros(1, round(max_time/dt));
    
    % Parse decision variables
    idx = 1;
    for i = 1:length(group.uavs)
        uav_id = group.uavs(i);
        n_bombs = group.bombs(i);
        
        % Extract UAV parameters
        v_mag = x(idx); idx = idx + 1;
        v_theta = x(idx); idx = idx + 1;
        
        % Process each bomb
        for b = 1:n_bombs
            t_deploy = x(idx); idx = idx + 1;
            t_fall = x(idx); idx = idx + 1;
            
            % Calculate smoke cloud trajectory
            [cloud_pos, active_period] = compute_cloud_trajectory(...
                uavs(uav_id), v_mag, v_theta, t_deploy, t_fall, constraints);
            
            % Check coverage for this cloud
            for t_idx = 1:length(active_period)
                t = active_period(t_idx);
                missile_pos = missile.pos - 300 * missile.pos/norm(missile.pos) * t;
                
                if t_idx <= size(cloud_pos, 1)
                    if check_shelf(cloud_pos(t_idx, :), missile_pos, constraints.cloud_radius)
                        t_blocked(round(t/dt)) = 1;
                    end
                end
            end
        end
    end
    
    coverage_time = sum(t_blocked) * dt;
end