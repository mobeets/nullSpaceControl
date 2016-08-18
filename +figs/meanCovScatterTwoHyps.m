function meanCovScatterTwoHyps(SVals, nms, ixMnk, hypNm1, hypNm2, lbl, ix)

if nargin < 7
    ix = true(size(SVals,1),1);
end

hypInd1 = find(strcmp(nms, hypNm1));
hypInd2 = find(strcmp(nms, hypNm2));
xs = SVals(ix,hypInd1);
ys = SVals(ix,hypInd2);

if strcmp(lbl, 'mean')    
    xstep = 1;
else
    xstep = 25;
end

sz = 10;

plot.init;
plot(xs(ixMnk(ix)), ys(ixMnk(ix)), 'ko', 'MarkerFaceColor', 'k', ...
    'MarkerSize', sz); 
plot(xs(~ixMnk(ix)), ys(~ixMnk(ix)), 'ks', 'MarkerFaceColor', 'k', ...
    'MarkerSize', sz);
xlabel([lbl ' error, ' hypNm1]);
ylabel([lbl ' error, ' hypNm2]);
xmx = ceil(max([xs; ys]));
tcks = 0:xstep:xmx;
xlim([0 xmx]); ylim(xlim);
set(gca, 'XTick', tcks);
set(gca, 'YTick', tcks);
plot(xlim, ylim, 'k--');
axis square;

end
