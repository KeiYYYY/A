clear; clc; close all;

lb_phy = [70 0 70 0 70 0 70 0 70 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0];
ub_phy = [140 2*pi 140 2*pi 140 2*pi 140 2*pi 140 2*pi 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40 40];

objFun = @cal_shelf_norm;      % 目标函数句柄
nVar   = 40;                    % 维度
lb     = -ones(1,nVar);         % 下界
ub     =  ones(1,nVar);         % 上界

opts = struct(...
    'MaxGen',  500, ...
    'PopSize', 200, ...
    'F',       0.8, ...
    'CR',      0.9, ...
    'display', true, ...
    'plot',    true ...
    );

[xBest, fBest, deHist] = DE(objFun, lb, ub, opts);

x_phy_best = (xBest + 1)/2 .* (ub_phy - lb_phy) + lb_phy;
fprintf('最优物理解：'); 
disp(x_phy_best);
[t1, t2, t3] = cal_shelf(xBest);
fprintf('三阶段时间：%.3f, %.3f, %.3f s\n', t1, t2, t3);
fprintf("总时间：%.2f", (t1+t2+t3));

%%
function [xBest, fBest, hist] = DE(fun, lb, ub, opts)
    % 基本参数
    MaxGen  = getOption(opts, 'MaxGen', 500);
    NP      = getOption(opts, 'PopSize', 100);
    F       = getOption(opts, 'F', 0.8);
    CR      = getOption(opts, 'CR', 0.9);
    display = getOption(opts, 'display', true);
    doplot  = getOption(opts, 'plot', true);
    nVar    = numel(lb);

    % 增强选项：自适应参数、p-best变异、移民、多样性重启、边界反射
    UseJDE     = getOption(opts, 'UseJDE', true);      % 自适应F/CR (jDE)
    Tau1       = getOption(opts, 'Tau1', 0.1);         % 更新F概率
    Tau2       = getOption(opts, 'Tau2', 0.1);         % 更新CR概率
    F_lower    = getOption(opts, 'F_lower', 0.1);
    F_upper    = getOption(opts, 'F_upper', 0.9);      % F∈[F_lower, F_lower+F_upper]
    UsePBest   = getOption(opts, 'UsePBest', true);    % 启用current-to-pbest/1
    PBestFrac  = getOption(opts, 'PBestFrac', 0.2);    % p-best比例
    PBestRate  = getOption(opts, 'PBestRate', 0.8);    % 使用p-best的概率
    ImmRate    = getOption(opts, 'Immigrants', 0.02);  % 每代随机移民比例
    StallGen   = getOption(opts, 'StallGen', round(MaxGen/6)); % 停滞触发阈值
    ReinitFrac = getOption(opts, 'ReinitFrac', 0.3);   % 重启比例
    Boundary   = lower(string(getOption(opts, 'Boundary', 'reflect')));
    ArchCap    = getOption(opts, 'ArchiveSize', NP);   % 外部档案上限

    % 初始化
    X  = repmat(lb, NP, 1) + rand(NP, nVar) .* repmat(ub - lb, NP, 1);
    fX = arrayfun(@(i) fun(X(i, :)), 1:NP);
    [fBest, idx] = min(fX);
    xBest = X(idx, :);
    hist  = struct('best', [], 'mean', []);
    hist(1).best = fBest;
    hist(1).mean = mean(fX);

    % 个体级参数(jDE)与外部档案(JADE)
    Fi   = F  * ones(NP, 1);
    CRi  = CR * ones(NP, 1);
    Arch = zeros(0, nVar);

    stallCount = 0;

    % 主循环
    for gen = 1:MaxGen
        Xnew = X;  % 先拷贝，成功选择后覆盖

        % p-best候选池
        [~, sortIdx] = sort(fX, 'ascend');
        pCount = max(2, ceil(PBestFrac * NP));
        pPool  = sortIdx(1:pCount);

        for i = 1:NP
            % jDE自适应
            if UseJDE
                if rand < Tau1, Fi(i)  = F_lower + F_upper * rand; end
                if rand < Tau2, CRi(i) = rand; end
            end

            usePB = (UsePBest && rand <= PBestRate);

            if usePB
                % JADE: current-to-pbest/1 带外部档案
                pbest = pPool(randi(pCount));
                cand = 1:NP; cand([i pbest]) = [];
                r1 = cand(randi(numel(cand)));
                if ~isempty(Arch) && rand < (size(Arch,1) / (size(Arch,1) + NP))
                    r2v = Arch(randi(size(Arch,1)), :);
                else
                    cand2 = 1:NP; cand2([i pbest r1]) = [];
                    r2 = cand2(randi(numel(cand2)));
                    r2v = X(r2, :);
                end
                V = X(i, :) + Fi(i) * (X(pbest, :) - X(i, :)) + Fi(i) * (X(r1, :) - r2v);
            else
                % 经典 DE/rand/1
                r = randperm(NP); r(r == i) = [];
                a = X(r(1), :); b = X(r(2), :); c = X(r(3), :);
                V = a + Fi(i) * (b - c);
            end

            % 边界处理
            V = repair_bounds(V, X(i, :), lb, ub, Boundary);

            % 交叉：二进制交叉
            mask = rand(1, nVar) <= CRi(i);
            if ~any(mask), mask(randi(nVar)) = true; end
            U = X(i, :); U(mask) = V(mask);

            % 选择 + 档案更新
            fU = fun(U);
            if fU <= fX(i)
                if ~isequal(U, X(i, :))
                    Arch(end+1, :) = X(i, :); %#ok<AGROW>
                    if size(Arch,1) > ArchCap
                        excess = size(Arch,1) - ArchCap;
                        Arch(randperm(size(Arch,1), excess), :) = [];
                    end
                end
                Xnew(i, :) = U;
                fX(i)      = fU;
            else
                Xnew(i, :) = X(i, :);
            end
        end

        X = Xnew;

        % 随机移民提升多样性
        if ImmRate > 0
            k = floor(ImmRate * NP);
            if k > 0
                [~, bestIdxNow] = min(fX);
                pool = setdiff(1:NP, bestIdxNow);
                if numel(pool) >= k
                    immIdx = pool(randperm(numel(pool), k));
                    R = repmat(lb, k, 1) + rand(k, nVar) .* repmat(ub - lb, k, 1);
                    for ii = 1:k
                        X(immIdx(ii), :) = R(ii, :);
                        fX(immIdx(ii))   = fun(X(immIdx(ii), :));
                        Fi(immIdx(ii))   = F;   % 新移民参数重置
                        CRi(immIdx(ii))  = CR;
                    end
                end
            end
        end

        % 精英保留 + 停滞检测
        [fmin, idx] = min(fX);
        if fmin < fBest
            fBest = fmin; xBest = X(idx, :); stallCount = 0;
        else
            stallCount = stallCount + 1;
            X(1, :) = xBest; fX(1) = fBest;  % 强制保留精英
        end

        % 停滞触发部分重启（最差个体重置）
        if StallGen > 0 && stallCount >= StallGen
            w = max(1, ceil(ReinitFrac * NP));
            [~, ord] = sort(fX, 'descend');
            worst = setdiff(ord(1:w), idx, 'stable');
            if ~isempty(worst)
                Rw = repmat(lb, numel(worst), 1) + rand(numel(worst), nVar) .* repmat(ub - lb, numel(worst), 1);
                for jj = 1:numel(worst)
                    X(worst(jj), :) = Rw(jj, :);
                    fX(worst(jj))   = fun(X(worst(jj), :));
                    Fi(worst(jj))   = F; CRi(worst(jj)) = CR;
                end
            end
            Arch = zeros(0, nVar);  % 重置档案
            stallCount = 0;
        end

        hist(gen).best = fBest;
        hist(gen).mean = mean(fX);

        if display && mod(gen, 50) == 0
            fprintf('Gen %5d: best f = %.2f\n', gen, -fBest);
        end
    end

    % 收敛曲线
    if doplot
        figure; plot([hist.best], 'LineWidth', 1.8);
        xlabel('Generation'); ylabel('Best f'); title('DE Convergence Curve'); grid on;
    end
end

% ------ Local helpers ------
function val = getOption(opts, name, default)
    if isstruct(opts) && isfield(opts, name)
        val = opts.(name);
    else
        val = default;
    end
end

function V = repair_bounds(V, Xi, lb, ub, mode)
    % mode: "reflect" (default) or "clip"
    switch char(mode)
        case 'clip'
            V = max(min(V, ub), lb);
        otherwise % 'reflect'
            low  = V < lb;  high = V > ub;
            if any(low)
                V(low) = lb(low) + rand(1, sum(low)) .* (Xi(low) - lb(low));
            end
            if any(high)
                V(high) = ub(high) - rand(1, sum(high)) .* (ub(high) - Xi(high));
            end
            V = max(min(V, ub), lb); % 最终裁剪
    end
end

