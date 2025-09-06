function solution = enhanced_multi_objective_optimization(missiles, uavs, constraints)
    % Main optimization loop with adaptive refinement
    
    % Initialize weights for multi-objective function
    weights.alpha = 0.4;  % Total protection
    weights.beta = 0.4;   % Fairness
    weights.gamma = 0.2;  % Threshold penalty
    
    % Phase 1: Game-theoretic allocation
    fprintf('Phase 1: Strategic allocation...\n');
    allocation = game_theoretic_allocation(missiles, uavs, constraints);
    print_allocation(allocation);
    
    % Phase 2: Iterative refinement
    fprintf('\nPhase 2: Iterative optimization...\n');
    best_solution = [];
    best_fitness = -inf;
    
    for iter = 1:5
        fprintf('  Iteration %d: ', iter);
        
        % Coordinate trajectory planning
        trajectories = coordinated_planning(allocation, missiles, uavs, constraints, weights);
        
        % Evaluate solution
        [T1, T2, T3] = evaluate_full_scenario(trajectories, allocation, missiles, uavs, constraints);
        total = T1 + T2 + T3;
        balance = min([T1, T2, T3]) / max([T1, T2, T3]);
        
        fprintf('T=[%.1f, %.1f, %.1f], Balance=%.2f\n', T1, T2, T3, balance);
        
        % Calculate fitness
        fitness = balanced_objective([T1, T2, T3], weights);
        
        if fitness > best_fitness
            best_fitness = fitness;
            best_solution = trajectories;
            best_solution.T1 = T1;
            best_solution.T2 = T2;
            best_solution.T3 = T3;
            best_solution.total = total;
            best_solution.balance = balance;
            best_solution.allocation = allocation;
        end
        
        % Adaptive weight adjustment
        if balance < 0.5
            weights.beta = min(0.6, weights.beta * 1.2);
            weights.alpha = weights.alpha * 0.9;
        elseif total < 15
            weights.alpha = min(0.6, weights.alpha * 1.1);
        end
        
        % Check for reallocation need
        if min([T1, T2, T3]) < 2.0
            worst = find([T1, T2, T3] == min([T1, T2, T3]), 1);
            allocation = emergency_reallocation(allocation, worst, [T1, T2, T3]);
        end
        
        % Early termination if good solution found
        if balance > 0.65 && total > 18 && min([T1, T2, T3]) > 3
            fprintf('  -> Satisfactory solution found!\n');
            break;
        end
    end
    
    % Phase 3: Local refinement
    fprintf('\nPhase 3: Local refinement...\n');
    solution = local_refinement(best_solution, missiles, uavs, constraints);
end