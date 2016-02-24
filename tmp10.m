
B1 = D.blocks(1);
NB1 = B1.fDecoder.NulM2;
YN1 = B1.latents*NB2;
[~,~,v] = svd(YN1);
YN1 = YN1*v;

B2 = D.blocks(2);
NB2 = B2.fDecoder.NulM2;
RB2 = B2.fDecoder.RowM2;
YN2 = B2.latents*NB2;
[~,~,v] = svd(YN2);
YN2 = YN2*v;

%%

B = B2;
% YN = YN2;
YN = B2.latents*RB2;

gs = B.thetaGrps;
grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));

figure; set(gcf, 'color', 'w');

for ig = 1:numel(grps)
    grp = grps(ig);

    ix = gs == grp;
    trs = B.trial_index;
    ts = unique(trs);

    yc = nan(numel(ts), size(YN,2));
    for ii = 1:numel(ts)
        ixc = ix & (ts(ii) == trs);
        yc(ii,:) = nanmean(YN(ixc,:));
%         yc(ii,:) = nanvar(YN2(ixc,:));
    end
    yc = yc(~any(isnan(yc),2),:);

    subplot(4,2,ig); hold on;
    plot(yc(:,2), '.', 'Color', clrs(ig,:), 'LineWidth', 3);
    clr = clrs(ig,:);
%     plot(yc(:,2), '.', 'Color', clr, 'LineWidth', 3);
    xlim([0 250]);
% 	ylim([-10 10]);
end
xlabel('time');
ylabel('activity');

%%


close all;
figure;
hold on;

y = yc(:,1);
[cc, lg] = xcorr(y);
plot(lg, cc);

y = yc(:,2);
[cc, lg] = xcorr(y);
plot(lg, cc);

y = yc(:,3);
[cc, lg] = xcorr(y);
plot(lg, cc);
