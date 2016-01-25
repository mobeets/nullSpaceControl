
% figure;
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];
% plot.blkSummary(D.blocks(2), [], [], false, true, clr1);
% plot.blkSummary(D.blocks(2), [], H, false, true, clr2);
plot.blkSummary(D.blocks(2), [], H, true, true, clr2);
plot.subtitle(['observed [blue] vs ' H.name ' [red] in null(B2)'], ...
    'FontSize', 14);
