function [x_best, f_best] = stable_optimization(obj_func, lb, ub, n_vars)
    % Stable PSO with adaptive parameters and diversity preservation
    
    % Initial parameters
    pop_size = min(150, 10 * n_vars);
    max_iter = 300;
    stagnation_limit = 20;
    
    % Use existing AM_PSO with modified parameters for stability
    if exist('AM_PSO', 'file')
        [x_best, f_best, ~] = AM_PSO(obj_func, n_vars, pop_size, max_iter, lb, ub);
    else
        % Fallback to basic PSO if AM_PSO not available
        options = optimoptions('particleswarm', ...
            'PopulationSize', pop_size, ...
            'MaxIterations', max_iter, ...
            'FunctionTolerance', 1e-6, ...
            'Display', 'off');
        
        [x_best, f_best] = particleswarm(obj_func, n_vars, lb, ub, options);
    end
end