function y = cal_shelf_norm(x_norm)
% 统一入口：x_norm 永远是 1×12，每维 ∈ [-1,1]
% 先反向映射到物理量，再调用原始黑箱
lb = [70 0 70 0 70 0 0 0 0 0 0 0];
ub = [140 2*pi 140 2*pi 140 2*pi 10 15 10 15 10 15];

% 线性逆映射：[-1,1] -> [lb,ub]
x_phy = (x_norm + 1)/2 .* (ub - lb) + lb;

% 现在 x_phy 是 1×12 的物理量，喂给原函数
y = cal_shelf_phy(x_phy);   % 见第 2 步
end