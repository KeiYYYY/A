function trajectories = coordinated_planning(allocation, missiles, uavs, constraints, weights)
    % Coordinate trajectory planning for all UAV-missile assignments
    
    n_uavs = size(allocation, 1);
    n_missiles = size(allocation, 2);
    
    % Group UAVs by target missile
    for m = 1:n_missiles
        groups{m}.uavs = find(allocation(:, m) > 0);
        groups{m}.bombs = allocation(groups{m}.uavs, m);
    end
    
    % Optimize each missile group in parallel
    trajectories = [];
    
    parfor m = 1:n_missiles
        if ~isempty(groups{m}.uavs)
            fprintf('    Optimizing missile M%d defense...\n', m);
            
            % Construct optimization problem for this group
            missile_name = sprintf('M%d', m);
            missile_data = missiles.(missile_name);
            
            % Build decision variable bounds
            n_vars = 0;
            lb = []; ub = [];
            
            for idx = 1:length(groups{m}.uavs)
                uav_id = groups{m}.uavs(idx);
                n_bombs = groups{m}.bombs(idx);
                
                % UAV flight parameters (v_mag, v_theta)
                lb = [lb, constraints.v_min, 0];
                ub = [ub, constraints.v_max, 2*pi];
                n_vars = n_vars + 2;
                
                % Bomb deployment parameters (t_deploy, t_fall) for each bomb
                for b = 1:n_bombs
                    lb = [lb, 0, 0];
                    ub = [ub, 15, 10];
                    n_vars = n_vars + 2;
                end
            end
            
            % Create objective function for this missile
            obj_func = @(x) -calculate_missile_coverage(x, groups{m}, ...
                                                        missile_data, uavs, constraints);
            
            % Run optimization with stable PSO
            [x_opt, f_opt] = stable_optimization(obj_func, lb, ub, n_vars);
            
            % Store optimized trajectories
            group_trajectories{m} = decode_trajectory(x_opt, groups{m}, uav_id);
            group_shields(m) = -f_opt;
        else
            group_trajectories{m} = [];
            group_shields(m) = 0;
        end
    end
    
    % Combine all trajectories
    trajectories.groups = group_trajectories;
    trajectories.shields = group_shields;
end