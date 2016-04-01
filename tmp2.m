
% showing that 3d is enough to capture most of null activity

%%

clear all;
% close all;

D = fitByDate('20120601', [], {'habitual'}, [], [], struct('decoderNm', 'fImeDecoder'));
Y = D.blocks(2).latents;
Y1 = D.hyps(2).latents;
NB = D.blocks(2).fDecoder.NulM2;

[u,s,v] = svd(D.blocks(1).latents*NB);
Y2 = Y1*NB*v;
Y2(:,4:end) = 0;
Y2 = Y2*v';
Y2 = Y2*NB';
D.hyps(3) = D.hyps(2);
D.hyps(3).latents = Y2;

[u,s,v] = svd(Y1*NB);
Y2 = Y1*NB*v;
Y2(:,4:end) = 0;
Y2 = Y2*v';
Y2 = Y2*NB';
D.hyps(4) = D.hyps(2);
D.hyps(4).latents = Y2;

D = pred.nullActivity(D);
D = score.scoreAll(D);

figure; plot.allErrorByKin(D, D.hyps(2:end))

%%

% hypopts = struct('decoderNm', 'fImeDecoder'));
D = fitByDate('20120601', ...
    {'cloud-hab', 'conditional', 'conditional-thetas'}, ...
    [], hypopts);
figure; plot.allErrorByKin(D, D.hyps(2:end))

%%

B = D.blocks(2);
Y = B.latents;
NB = B.fDecoder.NulM2;
[u,s,v] = svd(B.latents*NB);
Y2 = Y*NB*v;

%% viewing null activity in 3d

Y2p = Y2(:,1:3);

xs = B.targetAngle;
gs = sort(unique(xs));
clrs = cbrewer('div', 'RdYlGn', numel(gs));

figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);
for ii = 1:numel(gs)
    ix = gs(ii) == xs;
%     plot3(Y2p(ix,1), Y2p(ix,2), Y2p(ix,3), 'k.');
    plot3(Y2p(ix,1), Y2p(ix,2), Y2p(ix,3), '.', 'Color', clrs(ii,:))
%     plot3(nanmean(Y2p(ix,1)), nanmean(Y2p(ix,2)), nanmean(Y2p(ix,3)), 'ko', 'MarkerFaceColor', clrs(ii,:))
end

