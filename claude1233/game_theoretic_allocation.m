function allocation = game_theoretic_allocation(missiles, uavs, constraints)
    % Game-theoretic resource allocation based on threats and efficiency
    
    n_uavs = length(uavs);
    n_missiles = 3;
    max_bombs = constraints.max_bombs;
    
    % Calculate threat levels for each missile
    for m = 1:n_missiles
        missile_name = sprintf('M%d', m);
        pos = missiles.(missile_name).pos;
        distance(m) = norm(pos);
        arrival_time(m) = distance(m) / 300;  % 300 m/s missile speed
        
        % Threat score (closer = higher threat)
        threat(m) = 1 / arrival_time(m);
    end
    
    % Normalize threats
    threat = threat / sum(threat);
    
    % Calculate UAV-missile efficiency matrix
    for u = 1:n_uavs
        for m = 1:n_missiles
            missile_name = sprintf('M%d', m);
            missile_pos = missiles.(missile_name).pos;
            
            % Time to intercept position
            intercept_dist = norm(uavs(u).pos - missile_pos * 0.8);
            time_to_position = intercept_dist / 105;  % Average speed
            
            % Efficiency score
            efficiency(u, m) = 1 / (1 + time_to_position);
        end
    end
    
    % Initialize allocation matrix (UAVs x Missiles)
    allocation = zeros(n_uavs, n_missiles);
    total_bombs = n_uavs * max_bombs;
    
    % Distribute bombs proportional to threats, considering efficiency
    target_bombs = round(threat * total_bombs);
    target_bombs = min(target_bombs, total_bombs);  % Ensure we don't exceed
    
    % Greedy allocation based on efficiency
    bombs_remaining = ones(n_uavs, 1) * max_bombs;
    
    for m = 1:n_missiles
        bombs_needed = target_bombs(m);
        
        while bombs_needed > 0
            % Find most efficient available UAV for this missile
            available_efficiency = efficiency(:, m) .* (bombs_remaining > 0);
            [~, best_uav] = max(available_efficiency);
            
            if available_efficiency(best_uav) == 0
                break;  % No more UAVs available
            end
            
            % Allocate one bomb
            allocation(best_uav, m) = allocation(best_uav, m) + 1;
            bombs_remaining(best_uav) = bombs_remaining(best_uav) - 1;
            bombs_needed = bombs_needed - 1;
        end
    end
    
    % Ensure minimum coverage for each missile
    for m = 1:n_missiles
        if sum(allocation(:, m)) < 2
            % Find UAV with spare capacity
            [spare, idx] = max(bombs_remaining);
            if spare > 0
                allocation(idx, m) = allocation(idx, m) + 1;
                bombs_remaining(idx) = bombs_remaining(idx) - 1;
            end
        end
    end
end