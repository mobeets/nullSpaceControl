
figure;
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];
plot.blkSummary(D.blocks(2), [], [], false, true, clr1);
plot.blkSummary(D.blocks(1), D.blocks(2), [], false, true, clr2);
plot.subtitle('B2 [blue] vs B1 [red] in null(B2)', 'FontSize', 14);
