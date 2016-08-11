function meanCovScatterTwoHyps(SMu, SCov, nms, hypNm1, hypNm2, lbl)

hypInd1 = find(strcmp(nms, hypNm1));
hypInd2 = find(strcmp(nms, hypNm2));

if strcmp(lbl, 'mean')
    xs = SMu(:,hypInd1);
    ys = SMu(:,hypInd2);
    xstep = 1;
else
    xs = SCov(:,hypInd1);
    ys = SCov(:,hypInd2);
    xstep = 25;
end

plot.init;
plot(xs, ys, 'k.', 'MarkerSize', 40);
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
