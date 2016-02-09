
S = D.simpleData;
xs = S.targetAngles;
ys = S.movementTime;

gs = sort(unique(xs));

blk1 = false(numel(ys), 1);
blk1(unique(D.blocks(2).trial_index)) = true;
xs = xs(blk1);
ys = ys(blk1);


nbins = 2;
bins = linspace(1, numel(ys), nbins+1);
inds = 1:numel(ys);
ysm = nan(numel(gs), nbins);
nsm = nan(numel(gs), nbins);
for ii = 1:numel(gs)
    for jj = 1:nbins
        ix0 = inds >= bins(jj) & inds < bins(jj+1);
        ix1 = (gs(ii) == xs)';
        ysm(ii,jj) = nanmedian(ys(ix0 & ix1));
        nsm(ii,jj) = sum(ix0 & ix1);
    end
end

figure; set(gcf, 'color', 'w');
hold on; box off; set(gca, 'FontSize', 14);
clrs = cbrewer('seq', 'Reds', size(ysm,2));
% for ii = 1:size(ysm,2)
%     plot(gs, ysm(:,ii), '-', 'Color', clrs(size(ysm,2)-ii+1,:), ...
%         'LineWidth', 3);
% end

plot(gs, ysm(:,1) - ysm(:,end), '-', 'Color', clrs(end,:), ...
    'LineWidth', 3);
title(D.datestr);
