function [gBest,gBestFit,trace] = AM_PSO(fitfcn,D,pop,maxIt,xMin,xMax)
% 自适应增强 PSO（AM-PSO）
% fitfcn: 适应度函数句柄；D: 维度；pop: 种群规模；maxIt: 迭代次数
% xMin/xMax: 1xD 下/上界
% 返回 gBest: 1xD 全局最优；gBestFit: 最优适应度；trace: 每代的最优值

% 工具箱检测（缺失则报错并停止）
hasPCT = license('test','Distrib_Computing_Toolbox') && ~isempty(ver('parallel'));
if ~hasPCT
    fprintf(2, '错误: 未检测到 Parallel Computing Toolbox，AM_PSO 无法并行运行。\n');
    error('ParallelComputingToolboxMissing');
end

%% 1 初始化
c1 = 2.05; c2 = 2.05; ksi = 0.729;          % 标准收敛因子设置
x = xMin + rand(pop,D).*(xMax-xMin);          % 位置
v = zeros(pop,D);                             % 速度
p = x;                                        % pbest

% 首次适应度并行计算
fp = zeros(pop,1);                             % 适应度
parfor i = 1:pop
    fp(i) = fitfcn(x(i,:));
end
[gBestFit,idx] = min(fp); gBest = p(idx,:);   % gbest
trace = zeros(maxIt,1);

%% 2 主循环
for it = 1:maxIt
    w = 0.9 - 0.5*it/maxIt;                   % 线性递减惯性权重
    
    % 2.1 标准速度-位置更新
    r1 = rand(pop,D); r2 = rand(pop,D);
    v = ksi*(w*v + c1*r1.*(p-x) + c2*r2.*(gBest(ones(pop,1),:)-x));
    x = x + v;
    x = max(min(x,xMax),xMin);                % 边界处理
    
    % 2.2 计算当前适应度（并行）
    f = zeros(pop,1);
    parfor i = 1:pop
        f(i) = fitfcn(x(i,:));
    end
    
    % 2.3 更新 pbest / gbest
    better = f < fp;  p(better,:) = x(better,:);  fp(better) = f(better);
    [bestFit,bestIdx] = min(fp);
    if bestFit < gBestFit,  gBestFit = bestFit; gBest = p(bestIdx,:); end
    
    % 2.4 自适应增强
    % ---- 2.4.1 基于一阶统计（聚集度）
    favg = mean(fp);  denom = max([abs(max(fp)-favg),abs(min(fp)-favg)]);
    if denom==0, denom=eps; end
    sigma2 = mean((fp - favg).^2)/denom^2;    % 0~1，越小越聚集
    
    % ---- 2.4.2 全局最优扰动概率
    Pm_g = 1 - sigma2;                        % 聚集越高，越要扰动
    if rand < Pm_g
        eta1 = randn(1,D);  eta2 = tan(pi*(rand(1,D)-0.5)); % 高斯+柯西
        gBest_mut = gBest + 0.1*(eta1+eta2).*(xMax-xMin);
        gBest_mut = max(min(gBest_mut,xMax),xMin);
        f_mut = fitfcn(gBest_mut);
        if f_mut < gBestFit, gBest = gBest_mut; gBestFit = f_mut; end
    end
    
    % ---- 2.4.3 最差 pbest 小波扰动
    [~,worstIdx] = max(fp);
    Pm_p = sigma2;                            % 聚集越低，越要扰动
    if rand < Pm_p
        a = 0.5 + 0.5*rand;  t = 2*rand-1;
        m = exp(-abs(t)/a) * sin(3*pi*t/a);   % Morlet 小波
        xMut = p(worstIdx,:) + 0.05*m.*(xMax-xMin);
        xMut = max(min(xMut,xMax),xMin);
        fMut = fitfcn(xMut);
        if fMut < fp(worstIdx)
            p(worstIdx,:) = xMut;  fp(worstIdx) = fMut;
        end
    end
    
    trace(it) = gBestFit;
end
end
