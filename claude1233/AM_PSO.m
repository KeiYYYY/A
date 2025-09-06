function [gBest,gBestFit,trace] = AM_PSO(fitfcn,D,pop,maxIt,xMin,xMax)
% 自适应变异 PSO（AM-PSO）
% fitfcn  句柄，D 维数，pop 规模，maxIt 迭代次数
% xMin/xMax 1×D 边界
% 输出：gBest 1×D 最优解，gBestFit 最优值，trace 收敛曲线

%% 1 初始化
c1 = 2.05; c2 = 2.05; ksi = 0.729;          % 标准压缩因子
x = xMin + rand(pop,D).*(xMax-xMin);          % 位置
v = zeros(pop,D);                             % 速度
p = x;                                        % pbest
fp = arrayfun(@(i)fitfcn(x(i,:)),1:pop);      % 适应度
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
    
    % 2.2 计算当前适应度
    f = arrayfun(@(i)fitfcn(x(i,:)),1:pop);
    
    % 2.3 更新 pbest / gbest
    better = f < fp;  p(better,:) = x(better,:);  fp(better) = f(better);
    [bestFit,bestIdx] = min(fp);
    if bestFit < gBestFit,  gBestFit = bestFit; gBest = p(bestIdx,:); end
    
    % 2.4 自适应变异
    % ---- 2.4.1 计算归一化方差（聚集度）
    favg = mean(fp);  denom = max([abs(max(fp)-favg),abs(min(fp)-favg)]);
    if denom==0, denom=eps; end
    sigma2 = mean((fp - favg).^2)/denom^2;    % 0→1，越小越聚集
    
    % ---- 2.4.2 全局最优混合变异概率
    Pm_g = 1 - sigma2;                        % 聚集→高概率
    if rand < Pm_g
        eta1 = randn(1,D);  eta2 = tan(pi*(rand(1,D)-0.5)); % 高斯+柯西
        gBest_mut = gBest + 0.1*(eta1+eta2).*(xMax-xMin);
        gBest_mut = max(min(gBest_mut,xMax),xMin);
        f_mut = fitfcn(gBest_mut);
        if f_mut < gBestFit, gBest = gBest_mut; gBestFit = f_mut; end
    end
    
    % ---- 2.4.3 最差 pbest 小波变异
    [~,worstIdx] = max(fp);
    Pm_p = sigma2;                            % 聚集→低概率
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