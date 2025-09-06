function total = cal_shelf(v_mag, v_theta, t_uav_1, t_descend_1, t_delta_2, t_descend_2, t_delta_3, t_descend_3)
vx = v_mag * cos(v_theta);    % 速度x分量 = 幅值 × cos(角度)
vy = v_mag * sin(v_theta);    % 速度y分量 = 幅值 × sin(角度)

pos_missle_initial = [20000, 0, 2000];    % 导弹初始位置
v_missle = v_cal(pos_missle_initial);     % 计算导弹速度

% 无人机（UAV）相关参数
v_uav = [vx, vy, 0];                      % 无人机速度（z轴速度为0）
pos_uav_initial = [17800, 0, 1800];       % 无人机初始位置

% 烟幕
g = [0, 0, -9.8];
v_cloud = [0, 0, -3];
r_cloud = 10;
t_cloud = 20;


% 细步长逐步计算是否遮蔽
gap = 0.01;
t_shelf = zeros(1, length(0:gap:(t_uav_1 + t_descend_1 + t_delta_2 + t_descend_2 + t_delta_3 + t_descend_3 + t_cloud)));
for k = 1:3
    if k == 1
        pos_missle = pos_missle_initial + v_missle*(t_uav_1 + t_descend_1);
        pos_uav = pos_uav_initial + v_uav*(t_uav_1 + t_descend_1);
        pos_cloud = pos_uav + 0.5*g*(t_descend_1)^2;
        s = t_uav_1 + t_descend_1;
    elseif k == 2
        pos_missle = pos_missle_initial + v_missle*(t_uav_1 + t_delta_2 + t_descend_2);
        pos_uav = pos_uav_initial + v_uav*(t_uav_1 + t_delta_2 + t_descend_2);
        pos_cloud = pos_uav + 0.5*g*(t_descend_2)^2;
        s = t_delta_2 + t_descend_2 + t_uav_1;
    else
        pos_missle = pos_missle_initial + v_missle*(t_uav_1 + t_delta_2 + t_delta_3 + t_descend_3);
        pos_uav = pos_uav_initial + v_uav*(t_uav_1 + t_delta_2 + t_delta_3 + t_descend_3);
        pos_cloud = pos_uav + 0.5*g*(t_descend_3)^2;
        s = t_uav_1 + t_delta_2 + t_delta_3 + t_descend_3 ;
    end

    for i = (0:gap:t_cloud) + s
        pos_missle = pos_missle + gap*v_missle;
        pos_cloud = pos_cloud + gap*v_cloud;
        if check(pos_cloud, pos_missle, r_cloud) % 判断导弹是否在云团内部，在则直接视为遮蔽
            p = round(i/gap)+1;
            t_shelf(p) = 1;
        else
            if check_shelf(pos_cloud, pos_missle, r_cloud)
                p = round(i/gap)+1;
                t_shelf(p) = 1;
            end
        end
    end
end
% 计算有效遮蔽时长
total = sum(t_shelf)*gap - gap;
end