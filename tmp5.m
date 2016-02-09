
X = D.hyps(1).latents;
X = [X ones(size(X,1),1)];
y = D.blocks(2).thetas + 180;
y1 = sind(y);
w1 = (X'*X)\(X'*y1);
figure;
plot(X*w1, y1, '.');

y2 = cosd(y);
w2 = (X'*X)\(X'*y2);
figure;
plot(X*w, y2, '.');

[tools.rsq(X*w1, y1) tools.rsq(X*w2, y2)]

%%

B = D.blocks(2);
cnts = sort(unique(B.thetaGrps));
for ii = 1:numel(cnts)
%     ix = (B.thetaGrps == cnts(ii)) & B.trial_index < 461;
    ix = (B.thetaGrps == cnts(ii)) & B.trial_index > 673;
%     ix = (B.thetaGrps == cnts(ii));
    x = B.movementVector(ix,:);
    y = B.vec2target(ix,:);
    vs2{ii} = B.angError(ix);
%     vs2{ii} = arrayfun(@(jj) x(jj,:)*y(jj,:)'/norm(y(jj,:)), 1:size(x,1));
end

%%

figure; hold on;
for ii = 1:numel(vs)
    bar(cnts(ii), median(vs2{ii}) - median(vs{ii}));
%     bar(cnts(ii), median(vs{ii}));
%     plot(cnts(ii)*ones(size(vs{ii},1),1), vs{ii}, '.');
end

%%

B = D.blocks(1);
for ii = 1:numel(B.thetas)
    te = B.thetas(ii);
    tt = tools.computeAngle(B.movementVector(ii,:), [1; 0]);
    
end


