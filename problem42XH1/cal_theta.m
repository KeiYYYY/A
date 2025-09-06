function theta = cal_theta(O, A, B)
    % O为射线起点，A,B分别为两条射线的点， 计算夹角
    vec_OA = A - O;
    vec_OB = B - O;
    % 计算余弦值
    cos_theta = dot(vec_OA, vec_OB) / (norm(vec_OA) * norm(vec_OB));
    theta = acos(cos_theta);
end