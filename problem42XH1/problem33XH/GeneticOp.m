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