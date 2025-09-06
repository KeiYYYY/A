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