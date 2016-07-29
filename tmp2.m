
nm1 = cellfun(@(d) [d ': 1-3'], {D.score(2:end).name}, 'uni', 0);
nm2 = cellfun(@(d) [d ': 2-3'], {D.score(2:end).name}, 'uni', 0);
nma = [nm1 nm2];
[~,ix] = sort(nma);

ss = cell2mat(S([2 3 5:size(S,1)],:));
plot.init;
% subplot(1,2,1); hold on;
sz = 20;
plot(ss(:,1), ss(:,4), '.', 'MarkerSize', sz);
plot(ss(:,2), ss(:,5), '.', 'MarkerSize', sz);
plot(ss(:,3), ss(:,6), '.', 'MarkerSize', sz);
xl = tools.getLims(ss(:));
xl = [floor(xl(1)) ceil(xl(2))];
xlim(xl);
ylim(xlim);
plot(xlim, ylim, 'k--');
set(gca, 'XTick', xl(1):xl(2));
set(gca, 'YTick', xl(1):xl(2));
legend({D.score(2:end).name}, 'Location', 'BestOutside');
xlabel('mean error: Blk1 fitting Blk3');
ylabel('mean error: Blk2 fitting Blk3');

plot.init;
% subplot(1,2,2); hold on;
plot(angs(:,1), angs(:,2), 'k.', 'MarkerSize', sz);
xl = tools.getLims(angs(:));
xl = [floor(xl(1)) ceil(xl(2))];
xlim(xl);
ylim(xlim);
plot(xlim, ylim, 'k--');
xlabel('\theta(NB1, NB3)');
ylabel('\theta(NB2, NB3)');

%%
plot.init;
A = angs(~isnan(angs(:,1)),:);
plot(diff(A,[],2), ss(:,5)-ss(:,2), 'k.', 'MarkerSize', sz);


%%

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    D = io.quickLoadByDate(dts{ii});
    B1 = D.blocks(1);
    B2 = D.blocks(2);
%     NB1 = B1.fImeDecoder.NulM2;
%     NB2 = B2.fImeDecoder.NulM2;
    RB1 = B1.fImeDecoder.RowM2;
    RB2 = B2.fImeDecoder.RowM2;
    bins = 0:9:360;

    ths11 = B1.thetaActualsIme;
    % ths11 = tools.computeAngles(B1.latents*RB1);
    ths12 = tools.computeAngles(B1.latents*RB2);
    ths22 = B2.thetaActualsIme;
    % ths22 = tools.computeAngles(B2.latents*RB2);
    ths21 = tools.computeAngles(B2.latents*RB1);

    plot.init;
    subplot(2,2,1); hold on;
    hist(ths11, bins); title('B1 in RB1');
    subplot(2,2,2); hold on;
    hist(ths12, bins); title('B1 in RB2');
    subplot(2,2,3); hold on;
    hist(ths21, bins); title('B2 in RB1');
    subplot(2,2,4); hold on;
    hist(ths22, bins); title('B2 in RB2');
    plot.subtitle(dts{ii});
    saveas(gcf, 'plots/tmp.png');
end

%%

dts = io.getAllowedDates();

scs = nan(numel(dts),3,numel(grps));
crs = nan(numel(dts),2);
for ii = 1:numel(dts)
    X = load(fullfile('data', 'fits', dirNm, [dts{ii} '.mat'])); D = X.D;
    
    gs = D.blocks(2).thetaActuals;
    grps = D.score(2).grps;
    [cs, bs] = hist(gs, grps);
    plot.init;
    plot(grps, D.score(2).errOfMeansByKin);
    plot(grps, D.score(5).errOfMeansByKin);
    plot(grps, max(D.score(2).errOfMeansByKin)*cs/max(cs), 'k--');
    
    scs(ii,1,:) = D.score(2).errOfMeansByKin;
    scs(ii,2,:) = D.score(5).errOfMeansByKin;
    scs(ii,3,:) = cs;
    crs(ii,:) = [corr(squeeze(scs(ii,1,:)), squeeze(scs(ii,3,:))) ...
        corr(squeeze(scs(ii,2,:)), squeeze(scs(ii,3,:)))]
    
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
    set(gca, 'XTickLabelRotation', 45);
    title(dts{ii});
    saveas(gcf, 'plots/tmp.png');
end
