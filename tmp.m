

% first = @(x, inds) x(inds);
% mu = cell2mat(cellfun(@(x) x(1:2), ...
%     D.hyps(5).nullActivity.zMu, 'uni', 0)')';

NB = D.blocks(2).fDecoder.NulM2;
RB = D.blocks(2).fDecoder.RowM2;
NBn = D.blocks(2).nDecoder.NulM2;
RBn = D.blocks(2).nDecoder.RowM2;
[~,~,v] = svd(D.hyps(1).latents*NB);
gs = D.blocks(2).thetaActualGrps16;
grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

hind = 2;

plot.init;
subplot(1,2,1); hold on;
plot(0, 0, 'k.', 'MarkerSize', 25);
for ii = 1:numel(grps)
    ix = gs == grps(ii);
    mu = mean(D.hyps(hind).latents(ix,:)*RB);
    plot(mu(1), mu(2), 'o', 'MarkerSize', 25, 'Color', clrs(ii,:));
end
axis equal;

subplot(1,2,2); hold on;
plot(0, 0, 'k.', 'MarkerSize', 25);
for ii = 1:numel(grps)
    ix = gs == grps(ii);
    mu = mean(D.hyps(hind).latents(ix,:)*NB*v);
    plot(mu(1), mu(2), 'o', 'MarkerSize', 25, 'Color', clrs(ii,:));
end
axis equal;

% for ii = 1:size(mu,1)
%     plot(mu(ii,1), mu(ii,2), 'o', 'MarkerSize', 25, 'Color', clrs(ii,:));
% end
