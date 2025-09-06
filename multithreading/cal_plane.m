function plane = cal_plane(P1, P2, P3)
% 计算过三点的平面标准方程
%   P1, P2, P3 - 三个点的坐标 [x, y, z]
%   A, B, C, D - 平面方程 Ax + By + Cz + D = 0 的系数
    % 向量
    v1 = P2 - P1;
    v2 = P3 - P1;
    % 法向量
    n = cross(v1, v2); 
    A = n(1); B = n(2); C = n(3);
    % 常数项 D
    D = -dot(n, P1);
    plane = [A, B, C, D];
end