function [cloud_positions, active_period] = compute_cloud_trajectory(uav, v_mag, v_theta, t_deploy, t_fall, constraints)
    % Compute smoke cloud position over time
    
    % UAV velocity vector
    v_uav = [v_mag * cos(v_theta), v_mag * sin(v_theta), 0];
    
    % Release position
    release_pos = uav.pos + v_uav * t_deploy;
    
    % Detonation position (after ballistic fall)
    g = [0, 0, -constraints.g];
    detonate_pos = release_pos + v_uav * t_fall + 0.5 * g * t_fall^2;
    
    % Cloud descent trajectory
    dt = 0.01;
    t_start = t_deploy + t_fall;
    t_end = t_start + constraints.cloud_duration;
    
    active_period = t_start:dt:t_end;
    n_steps = length(active_period);
    
    cloud_positions = zeros(n_steps, 3);
    descent_velocity = [0, 0, -constraints.cloud_descent];
    
    for i = 1:n_steps
        elapsed = (i-1) * dt;
        cloud_positions(i, :) = detonate_pos + descent_velocity * elapsed;
    end
end