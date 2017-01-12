
es = cell(numel(D.hyps), numel(dts));
for jj = 1:numel(dts)
    try
        [D, hypnms] = figs.exampleSession(fitNm, dts{jj});
    catch
        es{:,jj} = nan(16,8);
    end
    
    hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16', ...
        'obeyBounds', true, 'boundsType', 'spikes');
    hypopts.fitInLatent = false;
    hypopts.addSpikeNoise = true;
    D = rmfield(D, 'scores');
    D = rmfield(D, 'score');
    D = score.scoreAll(D, hypopts);
    
%     Z = D.hyps(1).marginalHist.Zs;
    for ii = 2:numel(D.hyps)
%         Zh = D.hyps(ii).marginalHist.Zs;
%         es{ii,jj} = score.histError(Z, Zh);
        es{ii,jj} = D.score(ii).histErrByKinByCol;
        if isempty(es{ii,jj})
            es{ii,jj} = nan(8,8);
        end
    end
end

%%

for ii = 1:size(es,1)
    for jj = 1:size(es,2)
        if isempty(es{ii,jj})
            es{ii,jj} = nan(8,8);
        end
    end
end

%%

% ff = @(y) nanmean(y(:));
% errs = cellfun(@(y) ff(y(:,1:2)), es);
errs = cellfun(@(y) nanmean(y(:)), es);
mus = nanmean(errs,2);
ses = nanstd(errs,[],2)./sqrt(nansum(~isnan(errs),2));
bs = [mus - 2*ses mus + 2*ses]';
plot.init;
figs.bar_oneDt(mus, hypnms, allHypClrs, 'Avg. histogram overlap (%)', bs);
ylim([0 1]);
set(gca, 'YTick', 0:0.2:1);
set(gca, 'YTickLabel', 0:20:100);

errsBase = errs;
% figs.bar_allDts(errs', hypnms, dts, allHypClrs, 'avg hist error');

%%

Zh = cellfun(@(y) ceil(y), Z, 'uni', 0);
sc = score.histError(Z, Zh)

%%

figure; set(gcf, 'color', 'w');
imagesc(1:numel(dts), 1:numel(hypnms), 1-errs);
caxis([0 1]);
dtn = cellfun(@str2num, dts);
set(gca, 'YTick', 1:numel(hypnms));
set(gca, 'YTickLabel', hypnms);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);

