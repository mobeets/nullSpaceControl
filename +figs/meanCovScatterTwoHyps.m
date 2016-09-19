function meanCovScatterTwoHyps(SVals, nms, ixMnk, ...
    hypNm1, hypNm2, lbl, ix, SErrs)

if nargin < 7
    ix = true(size(SVals,1),1);
end

hypInd1 = find(strcmp(nms, hypNm1));
hypInd2 = find(strcmp(nms, hypNm2));
xs = SVals(ix,hypInd1);
ys = SVals(ix,hypInd2);
if ~isempty(SErrs)
    esx = SErrs(ix,hypInd1);
    esy = SErrs(ix,hypInd2);
else
    esx = zeros(size(xs));
    esy = zeros(size(ys));
end

if strcmp(lbl, 'mean')
    xstep = 1;
else
    xstep = 25;
end

sz = 5;

plot.init;
plot(xs(ixMnk(ix)), ys(ixMnk(ix)), 'ko', 'MarkerFaceColor', 'k', ...
    'MarkerSize', sz);
plot(xs(~ixMnk(ix)), ys(~ixMnk(ix)), 'ks', 'MarkerFaceColor', 'k', ...
    'MarkerSize', sz);

xsc = xs(ixMnk(ix)); esxc = esx(ixMnk(ix));
ysc = ys(ixMnk(ix)); esyc = esy(ixMnk(ix));
for ii = 1:numel(xsc)
    plot([xsc(ii)-esxc(ii) xsc(ii)+esxc(ii)], [ysc(ii) ysc(ii)], ...
        '-k', 'LineWidth', 1);
    plot([xsc(ii) xsc(ii)], [ysc(ii)-esyc(ii) ysc(ii)+esyc(ii)], ...
        '-k', 'LineWidth', 1);
end

xsc = xs(~ixMnk(ix)); esxc = esx(~ixMnk(ix));
ysc = ys(~ixMnk(ix)); esyc = esy(~ixMnk(ix));
for ii = 1:numel(xsc)
    plot([xsc(ii)-esxc(ii) xsc(ii)+esxc(ii)], [ysc(ii) ysc(ii)], ...
        '-k', 'LineWidth', 1);
    plot([xsc(ii) xsc(ii)], [ysc(ii)-esyc(ii) ysc(ii)+esyc(ii)], ...
        '-k', 'LineWidth', 1);
end

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
