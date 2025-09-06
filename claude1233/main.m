%% Problem 5: Multi-UAV Multi-Missile Defense Strategy
% Main script for coordinating 5 UAVs against 3 missiles
clear; clc; close all;

%% Initialize Problem Parameters
% Missile positions and velocities
missiles.M1.pos = [20000, 0, 2000];
missiles.M2.pos = [19000, 600, 2100];
missiles.M3.pos = [18000, -600, 1900];
missiles.target = [0, 0, 0];  % Fake target
missiles.real_target = [0, 200, 0];  % Real target center

% UAV initial positions
uavs(1).pos = [17800, 0, 1800];     % FY1
uavs(2).pos = [12000, 1400, 1400];  % FY2
uavs(3).pos = [6000, -3000, 700];   % FY3
uavs(4).pos = [11000, 2000, 1800];  % FY4
uavs(5).pos = [13000, -2000, 1300]; % FY5

% System constraints
constraints.v_min = 70;
constraints.v_max = 140;
constraints.max_bombs = 3;
constraints.min_interval = 1.0;  % seconds between deployments
constraints.g = 9.8;
constraints.cloud_descent = 3;
constraints.cloud_radius = 10;
constraints.cloud_duration = 20;

%% Run Enhanced Multi-Objective Optimization
fprintf('Starting Problem 5 Optimization...\n');
fprintf('===============================\n');

tic;
solution = enhanced_multi_objective_optimization(missiles, uavs, constraints);
elapsed_time = toc;

%% Display Results
fprintf('\n=== OPTIMIZATION COMPLETE ===\n');
fprintf('Total runtime: %.2f minutes\n', elapsed_time/60);
fprintf('\nMissile Protection Summary:\n');
fprintf('---------------------------\n');
fprintf('M1: %.2f seconds\n', solution.T1);
fprintf('M2: %.2f seconds\n', solution.T2);
fprintf('M3: %.2f seconds\n', solution.T3);
fprintf('Total: %.2f seconds\n', solution.total);
fprintf('Balance ratio: %.2f%%\n', solution.balance*100);

%% Save to Excel
save_to_excel(solution, 'result3.xlsx');

%% Visualization
visualize_solution(solution, missiles, uavs);