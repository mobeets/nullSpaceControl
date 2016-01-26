
% figure;
clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];

% project onto axes of maximum variance in observed data
NB = D.blocks(2).fDecoder.NulM2;
[~,~,v] = svd(D.blocks(2).latents*NB);
NB = NB*v;

plot.blkSummary(D.blocks(2), [], [], false, true, clr1, NB);
plot.blkSummary(D.blocks(2), [], H, false, true, clr2, NB);
% plot.blkSummary(D.blocks(2), [], H, true, true, clr2);
plot.subtitle(['observed [blue] vs ' H.name ' [red] in null(B2)'], ...
    'FontSize', 14);
