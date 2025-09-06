clear, clc;
% 检查并行工具箱是否可用
hasPCT = license('test','Distrib_Computing_Toolbox') && ~isempty(ver('parallel'));
if ~hasPCT
    fprintf(2, '错误: 未检测到 Parallel Computing Toolbox，程序停止。\n');
    return;
end

% 初始化并行池（若未开启）
if isempty(gcp('nocreate'))
    try
        parpool('threads');   % 线程池（新版本更快）
    catch
        parpool('local');     % 回退到本地进程池
    end
end
D = 12;
lb = [70, 0, 70, 0, 70, 0, 0, 0, 0, 0, 0, 0];
ub = [140, 2*pi, 140, 2*pi, 140, 2*pi, 60, 30, 60, 30, 60, 30];
pop = 200;
maxIt = 500;
[xm,fm,trace] = AM_PSO(@cal_shelf, D, pop, maxIt, lb, ub);
plot(trace); xlabel('迭代'); ylabel('最优值');
title(['AM-PSO 收敛曲线, 最优=' num2str(-fm)]);
