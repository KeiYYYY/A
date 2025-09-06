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