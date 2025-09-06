clear, clc;
% 初始数据
% 导弹
pos_missle_initial = [20000, 0, 2000];
v_missle = v_cal(pos_missle_initial);

% 无人机
v_uav = [-120, 0, 0];
pos_uav_initial = [17800, 0, 1800];
t_uav = 1.5;

% 烟幕
t_descend = 3.6;
g = [0, 0, -9.8];
v_cloud = [0, 0, -3];
r_cloud = 10;
t_cloud = 20;
%%
% 5.1s后的位置
pos_missle = pos_missle_initial + v_missle*(t_uav + t_descend);
pos_uav = pos_uav_initial + v_uav*(t_uav + t_descend);
pos_cloud = pos_uav + 0.5*g*(t_descend)^2;
%%
% 细步长逐步计算是否遮蔽
gap = 0.01;
t_shelf = zeros(1, length(0:gap:t_cloud));
for i = 0:gap:t_cloud
    pos_missle = pos_missle + gap*v_missle;
    pos_cloud = pos_cloud + gap*v_cloud;
    if check(pos_cloud, pos_missle, r_cloud) % 判断导弹是否在云团内部，在则直接视为遮蔽
        p = int32(i/gap+1);
        t_shelf(p) = 1;
    else
        if check_shelf(pos_cloud, pos_missle, r_cloud)
            p = int32(i/gap+1);
            t_shelf(p) = 1;
        end
    end
end
%%
start = find(t_shelf, 1)*gap - gap;
ending = start + sum(t_shelf)*gap - gap;
total = sum(t_shelf)*gap - gap;
fprintf("遮蔽开始于：%.2fs, 结束于：%.2fs, 总时长：%.2fs", start, ending, total);