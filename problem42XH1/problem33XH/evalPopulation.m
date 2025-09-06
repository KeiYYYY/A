function fit = evalPopulation(pop)
    n = size(pop,1);    % 种群个体数量
    fit = zeros(n,1);   % 适应度结果存储数组
    parfor i = 1:n      % 并行计算（提升效率）
        x = pop(i,:);   % 第i个个体的参数
        % 直接传递8个参数至cal_shelf函数
        fit(i) = cal_shelf(x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8));
    end
end