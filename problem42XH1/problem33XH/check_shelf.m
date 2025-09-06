function k = check_shelf(pos_cloud, pos_missle, r_cloud)
% 判断此刻真目标是否成功被遮蔽
    pos_1 = [0, 200, 0]; % 下底面圆心
    pos_2 = [0, 200, 10]; % 上顶面圆心
    r = 7; % 底面半径
    
    plane1 = cal_plane(pos_missle, pos_cloud, pos_1);
    plane2 = cal_plane(pos_missle, pos_cloud, pos_2);
    
    % 计算四个"危险点"坐标
    n_plane1 = plane1(1:3);
    d1 = cross(n_plane1, [0, 0, 1]);
    if norm(d1) < 1e-9
        points_1 = []; 
    else
        d_unit1 = d1 / norm(d1); 
        points_1 = [(pos_1 + r * d_unit1); (pos_1 - r * d_unit1)]; 
    end

    n_plane2 = plane2(1:3);
    d2 = cross(n_plane2, [0, 0, 1]);
    if norm(d2) < 1e-9
        points_2 = [];
    else
        d_unit2 = d2 / norm(d2); 
        points_2 = [(pos_2 + r * d_unit2); (pos_2 - r * d_unit2)]; 
    end

    % 计算导弹和四个"危险点"的连线与云团中心连线的角度
    theta1 = cal_theta(pos_missle, pos_cloud, points_1(1, :));
    theta2 = cal_theta(pos_missle, pos_cloud, points_1(2, :));
    theta3 = cal_theta(pos_missle, pos_cloud, points_2(1, :));
    theta4 = cal_theta(pos_missle, pos_cloud, points_2(2, :));
    A = [theta1, theta2, theta3, theta4];

    % 若四个"危险点"的角度均小于切线锥的顶角，则真目标被云团遮掩
    if all(acos(sqrt(norm(pos_cloud-pos_missle)^2 - r_cloud^2)/norm(pos_cloud-pos_missle)) > A)
        k = 1;
    else
        k = 0;
    end
end