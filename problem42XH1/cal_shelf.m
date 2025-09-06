function total = cal_shelf(x)
v_mag_1     = x(1);  v_theta_1 = x(2);
v_mag_2     = x(3);  v_theta_2 = x(4);
v_mag_3     = x(5);  v_theta_3 = x(6);
t_uav_1     = x(7);  t_descend_1 = x(8);
t_uav_2     = x(9);  t_descend_2 = x(10);
t_uav_3     = x(11); t_descend_3 = x(12);
pos_missle_initial = [20000, 0, 2000];    % 导弹初始位置
v_missle = v_cal(pos_missle_initial);     % 计算导弹速度

% 无人机1相关参数
vx_1 = v_mag_1 * cos(v_theta_1);    % 速度x分量 = 幅值 × cos(角度)
vy_1 = v_mag_1 * sin(v_theta_1);    % 速度y分量 = 幅值 × sin(角度)
v_uav_1 = [vx_1, vy_1, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial_1 = [17800, 0, 1800];       % 无人机初始位置

% 无人机2相关参数
vx_2 = v_mag_2 * cos(v_theta_2);    % 速度x分量 = 幅值 × cos(角度)
vy_2 = v_mag_2 * sin(v_theta_2);    % 速度y分量 = 幅值 × sin(角度)
v_uav_2 = [vx_2, vy_2, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial_2 = [12000, 1400, 1400];       % 无人机初始位置

% 无人机3相关参数
vx_3 = v_mag_3 * cos(v_theta_3);    % 速度x分量 = 幅值 × cos(角度)
vy_3 = v_mag_3 * sin(v_theta_3);    % 速度y分量 = 幅值 × sin(角度)
v_uav_3 = [vx_3, vy_3, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial_3 = [6000, -3000, 700];       % 无人机初始位置

% 烟幕
g = [0, 0, -9.8];
v_cloud = [0, 0, -3];
r_cloud = 10;
t_cloud = 20;


% 细步长逐步计算是否遮蔽
gap = 0.01;
% 计算最大可能时间（导弹飞行时间+最长无人机时间+烟雾持续时间）
max_time = norm(pos_missle_initial) / norm(v_missle) + max([t_uav_1, t_uav_2, t_uav_3]) + t_cloud;
t_shelf = zeros(1, ceil(max_time/gap) + 1);  % 预分配足够长度的数组
for k = 1:3
    if k == 1
        pos_missle = pos_missle_initial + v_missle*(t_uav_1 + t_descend_1);
        pos_uav_1 = pos_uav_initial_1 + v_uav_1*(t_uav_1 + t_descend_1);
        pos_cloud_1 = pos_uav_1 + 0.5*g*(t_descend_1^2);
        pos_missle = pos_missle - gap*v_missle;
        pos_cloud_1 = pos_cloud_1 - gap*v_cloud;
        for i = (0:gap:t_cloud) + (t_uav_1 + t_descend_1)
            if check(pos_cloud_1, pos_missle, r_cloud) % 判断导弹是否在云团内部，在则直接视为遮蔽
                p = round(i/gap) + 1;
                t_shelf(p) = 1;
            else
                if check_shelf(pos_cloud_1, pos_missle, r_cloud)
                    p = round(i/gap) + 1;
                    t_shelf(p) = 1;
                end
            end
            pos_missle = pos_missle + gap*v_missle;
            pos_cloud_1 = pos_cloud_1 + gap*v_cloud;
        end
    elseif k == 2
        pos_missle = pos_missle_initial + v_missle*(t_uav_2 + t_descend_2);
        pos_uav_2 = pos_uav_initial_2 + v_uav_2*(t_uav_2 + t_descend_2);
        pos_cloud_2 = pos_uav_2 + 0.5*g*(t_descend_2^2);
        for i = (0:gap:t_cloud) + (t_uav_2 + t_descend_2)
            if check(pos_cloud_2, pos_missle, r_cloud) % 判断导弹是否在云团内部，在则直接视为遮蔽
                p = round(i/gap) + 1;
                t_shelf(p) = 1;
            else
                if check_shelf(pos_cloud_2, pos_missle, r_cloud)
                    p = round(i/gap) + 1;
                    t_shelf(p) = 1;
                end
            end
            pos_missle = pos_missle + gap*v_missle;
            pos_cloud_2 = pos_cloud_2 + gap*v_cloud;
        end
    else
        pos_missle = pos_missle_initial + v_missle*(t_uav_3 + t_descend_3);
        pos_uav_3 = pos_uav_initial_3 + v_uav_3*(t_uav_3 + t_descend_3);
        pos_cloud_3 = pos_uav_3 + 0.5*g*(t_descend_3)^2;
        pos_missle = pos_missle - gap*v_missle;
        pos_cloud_3 = pos_cloud_3 - gap*v_cloud;
        for i = (0:gap:t_cloud) + (t_uav_3 + t_descend_3)
            if check(pos_cloud_3, pos_missle, r_cloud) % 判断导弹是否在云团内部，在则直接视为遮蔽
                p = round(i/gap) + 1;
                t_shelf(p) = 1;
            else
                if check_shelf(pos_cloud_3, pos_missle, r_cloud)
                    p = round(i/gap) + 1;
                    t_shelf(p) = 1;
                end
            end
            pos_missle = pos_missle + gap*v_missle;
            pos_cloud_3 = pos_cloud_3 + gap*v_cloud;
        end
    end
end
% 计算有效遮蔽时长
total = -sum(t_shelf)*gap;
end