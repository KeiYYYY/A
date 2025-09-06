clc; clear; close all;
% 如需运行，记得多试几次，有概率在一开始就报错
% 遗传算法参数
nVar        = 4;
lb          = [ 70    0     0   0 ];    % 下限
ub          = [ 140  2*pi   10  15 ];    % 上限
popSize     = 150;
maxGen      = 300;
pc          = 0.8;       % 交叉概率
pm          = 0.3;       % 变异概率
etaC        = 20;        % 交叉分布指数
etaM        = 20;        % 变异分布指数

% 用拟随机序列初始化种群
% 创建nVar维的哈尔顿序列集合
p = haltonset(nVar, 'Skip', 1);    % 'Skip'=1 跳过首个可能偏差较大的点
% 生成popSize个在[0, 1]区间均匀分布的拟随机点
qrs_points = net(p, popSize);

% 将拟随机点缩放至搜索空间边界范围内
pop = lb + qrs_points .* (ub - lb);

fit = evalPopulation(pop);    % 计算适应度
[bestf,bestIdx] = max(fit);
bestX_ga = pop(bestIdx,:);    % 记录遗传算法初始最优解
trace = zeros(maxGen,2);      % 收敛曲线追踪

fprintf('初始最佳遮蔽时间 = %.3f 秒\n',bestf);

% 遗传算法主循环
figure('Name','收敛曲线'); hold on; grid on;
for gen = 1:maxGen
    matingPool = TournamentSelect(pop,fit,popSize);    % 锦标赛选择
    offspring  = GeneticOp(matingPool,pc,pm,etaC,etaM,lb,ub);    % 遗传操作（传入边界）
    offFit = evalPopulation(offspring);    % 计算子代适应度
    % 合并+精英截断
    [~,eliteI] = max(fit);
    newPop = [pop; offspring];
    newFit = [fit; offFit];
    [sortedF,sortedI] = sort(newFit,'descend');
    newPop = newPop(sortedI(1:popSize),:);
    newFit = sortedF(1:popSize);
    newPop(1,:) = pop(eliteI,:); newFit(1) = fit(eliteI);
    pop = newPop; fit = newFit;
    % 更新最优
    [curBest,curI] = max(fit);
    if curBest > bestf, bestf = curBest; bestX = pop(curI,:); end
    trace(gen,:) = [gen bestf];
    if mod(gen,20)==0 || gen==maxGen
        fprintf('Gen %3d  best=%.3f s  x=[%.2f %.2f %.2f %.2f]\n',...
                 gen,bestf,bestX);
    end
    plot(trace(:,1),trace(:,2),'b-'); xlabel('Generation'); ylabel('遮蔽时长/s');
    title(sprintf('Best=%.3f s',bestf));
    drawnow;
end
fprintf('最优遮蔽时长=%.2f s\n',bestf);
fprintf('最优变量  vx=%.2f  vy=%.2f  t_uav=%.2f  t_descend=%.2f\n',bestX);
%%
function O = GeneticOp(parents,pc,pm,etaC,etaM,lb,ub) % 新增lb、ub参数
n = size(parents,1);
nVar = size(parents,2);
O = parents;
for i = 1:2:n
    if i+1>n, break; end
    p1 = parents(i,:); p2 = parents(i+1,:);
    % SBX交叉
    if rand < pc
        for j = 1:nVar
            if abs(p1(j)-p2(j)) > 1e-14
                xl = min(p1(j),p2(j)); xu = max(p1(j),p2(j));
                rand_ = rand;
                if rand_ <= 0.5
                    beta = (2*rand_)^(1/(etaC+1));
                else
                    beta = (1/(2*(1-rand_)))^(1/(etaC+1));
                end
                c1 = 0.5*((xl+xu)-beta*(xu-xl));
                c2 = 0.5*((xl+xu)+beta*(xu-xl));
                p1(j) = c1; p2(j) = c2;
            end
        end
    end
    % 多项式变异
    p1 = PolyMut(p1,pm,etaM,lb,ub);
    p2 = PolyMut(p2,pm,etaM,lb,ub);
    O(i,:) = p1; O(i+1,:) = p2;
end

% 向变异函数传入边界参数
p1 = PolyMut(p1,pm,etaM,lb,ub);
p2 = PolyMut(p2,pm,etaM,lb,ub);
O(i,:) = p1; O(i+1,:) = p2;
end


function y = PolyMut(x,pm,etaM,lb,ub)
y = x;
for j = 1:numel(x)
    if rand < pm
        xl = lb(j); xu = ub(j);
        delta1 = (x(j)-xl)/(xu-xl);
        delta2 = (xu-x(j))/(xu-xl);
        rand_ = rand;
        mut_pow = 1/(etaM+1);
        if rand_ <= 0.5
            xy = 1-delta1;
            val = 2*rand_+(1-2*rand_)*(xy)^(etaM+1);
            deltaq = val^mut_pow-1;
        else
            xy = 1-delta2;
            val = 2*(1-rand_)+2*(rand_-0.5)*(xy)^(etaM+1);
            deltaq = 1-(val)^mut_pow;
        end
        y(j) = x(j)+deltaq*(xu-xl);
        y(j) = max(min(y(j),xu),xl);
    end
end
end

function total = cal_shelf(v_mag, v_theta, t_uav, t_descend)
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

pos_missle = pos_missle_initial + v_missle*(t_uav + t_descend);
pos_uav = pos_uav_initial + v_uav*(t_uav + t_descend);
pos_cloud = pos_uav + 0.5*g*(t_descend)^2;

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

start = find(t_shelf, 1)*gap - gap;
ending = start + sum(t_shelf)*gap - gap;
total = sum(t_shelf)*gap - gap;
fprintf("遮蔽开始于：%.2fs, 结束于：%.2fs, 总时长：%.2fs", start, ending, total);
end

function fit = evalPopulation(pop)
    n = size(pop,1);    % 种群个体数量
    fit = zeros(n,1);   % 适应度结果存储数组
    parfor i = 1:n      % 并行计算（提升效率）
        x = pop(i,:);   % 第i个个体的参数（[v_mag, v_theta, t_uav, t_descend]）
        % 直接传递4个参数至cal_shelf函数
        fit(i) = cal_shelf(x(1), x(2), x(3), x(4));
    end
end

function P = TournamentSelect(pop,fit,nPick)
n = length(fit);
P = zeros(nPick,size(pop,2));
for k = 1:nPick
    i1 = randi(n); i2 = randi(n);
    if fit(i1) > fit(i2)
        P(k,:) = pop(i1,:);
    else
        P(k,:) = pop(i2,:);
    end
end
end