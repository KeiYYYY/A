function [total1, total2, total3] = cal_shelf(x)
v_mag_1 = x(1);  v_theta_1 = x(2);
v_mag_2 = x(3);  v_theta_2 = x(4);
v_mag_3 = x(5);  v_theta_3 = x(6);
v_mag_4 = x(7);  v_theta_4 = x(8);
v_mag_5 = x(9);  v_theta_5 = x(10);
t_uav_1 = [x(11), 0, x(12:13)];
t_descend_1 = x(14:16);
t_uav_2 = [x(17), 0, x(18:19)];
t_descend_2 = x(20:22);
t_uav_3 = [x(23), 0, x(24:25)];
t_descend_3 = x(26:28);
t_uav_4 = [x(29), 0, x(30:31)];
t_descend_4 = x(32:34);
t_uav_5 = [x(35), 0, x(36:37)];
t_descend_5 = x(38:40);

% 导弹1的参数
pos_missle_1_initial = [20000, 0, 2000];    % 导弹初始位置
v_missle_1 = v_cal(pos_missle_1_initial);     % 计算导弹速度

% 导弹2的参数
pos_missle_2_initial = [19000, 600, 2100];    % 导弹初始位置
v_missle_2 = v_cal(pos_missle_2_initial);     % 计算导弹速度

% 导弹3的参数
pos_missle_3_initial = [18000, -600, 1900];    % 导弹初始位置
v_missle_3 = v_cal(pos_missle_3_initial);     % 计算导弹速度

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

% 无人机4相关参数
vx_4 = v_mag_4 * cos(v_theta_4);    % 速度x分量 = 幅值 × cos(角度)
vy_4 = v_mag_4 * sin(v_theta_4);    % 速度y分量 = 幅值 × sin(角度)
v_uav_4 = [vx_4, vy_4, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial_4 = [11000, 2000, 1800];       % 无人机初始位置

% 无人机5相关参数
vx_5 = v_mag_5 * cos(v_theta_5);    % 速度x分量 = 幅值 × cos(角度)
vy_5 = v_mag_5 * sin(v_theta_5);    % 速度y分量 = 幅值 × sin(角度)
v_uav_5 = [vx_5, vy_5, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial_5 = [13000, -2000, 1300];       % 无人机初始位置

% 烟幕
g = [0, 0, -9.8];
v_cloud = [0, 0, -3];
r_cloud = 10;
t_cloud = 20;

% 整合参数
v_uav = [v_uav_1;v_uav_2;v_uav_3;v_uav_4;v_uav_5];
pos_uav_initial = [pos_uav_initial_1;pos_uav_initial_2;pos_uav_initial_3;pos_uav_initial_4;pos_uav_initial_5];
pos_missle_initial = [pos_missle_1_initial;pos_missle_2_initial;pos_missle_3_initial];
v_missle = [v_missle_1;v_missle_2;v_missle_3];
t_descend = [t_descend_1;t_descend_2;t_descend_3;t_descend_4;t_descend_5];
t_uav = [t_uav_1;t_uav_2;t_uav_3;t_uav_4;t_uav_5];

% 细步长逐步计算是否遮蔽
gap = 0.1;
% 将时间轴拉长，保证不出现越界
max_time = norm(pos_missle_1_initial);
t_shelf = zeros(3, ceil(max_time/gap) + 1);  % 预分配足够长度的数组

% 判断遮蔽
for k = 1:3 % 对导弹遍历
    for i = 1:5 % 对无人机遍历
        for j = 1:3 % 对烟幕弹遍历
            s = t_uav(i, 1) + t_uav(i, j+1) + t_descend(i, j);
            pos_missle = pos_missle_initial(k, :) + v_missle(k, :)*s;
            pos_cloud = pos_uav_initial(i,:) + v_uav(i, :)*s + 0.5*g*t_descend(i, j)^2;
            for time = (0:gap:t_cloud) + s
                if check(pos_cloud, pos_missle, r_cloud)
                    p = round(time/gap) + 1;
                    t_shelf(k, p) = 1;
                else
                    if check_shelf(pos_cloud, pos_missle, r_cloud)
                        p = round(time/gap) + 1;
                        t_shelf(k, p) = 1;
                    end
                end
                pos_missle = pos_missle + gap*v_missle(k, :);
                pos_cloud = pos_cloud + gap*v_cloud;
            end
        end
    end
end

% 分别计算遮蔽时长
total1 = sum(t_shelf(1,:))*gap;
total2 = sum(t_shelf(2,:))*gap;
total3 = sum(t_shelf(3,:))*gap;
end