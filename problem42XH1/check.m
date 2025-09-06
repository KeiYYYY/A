function k = check(pos_1, pos_2, r)
% 判断导弹是否在云团内部
    if norm(pos_1 - pos_2) <= r
        k = 1;
    else
        k = 0;
    end
end 