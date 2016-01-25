
figure;
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];

B = D.blocks(2);
nbins = 4;
xs = B.trial_index;
ts = unique(xs);
bins = prctile(ts, linspace(0, 100, nbins+1));

cmap = cbrewer('seq', 'Blues', nbins+2);

for ii = 1:nbins
    ix = xs >= bins(ii) & xs <= bins(ii+1);
    plot.blkSummary(B, [], [], false, true, cmap(ii+2,:), [], ix);
end
plot.subtitle('observed by trial period [light to dark = early to late]', ...
    'FontSize', 14);
