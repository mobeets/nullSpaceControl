
nms = {'true', 'habitual', 'cloud-hab', 'cloud-raw', ...
    'unconstrained', 'mean shift', 'mean shift prune'};
% nms = {'habitual', 'mean shift', 'mean shift prune', 'cloud-hab'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps');%, ...
%     'thetaNm', 'thetaActuals', 'grpNm', 'thetaActualGrps');
% hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaGrps16');
lopts = struct('postLoadFcn', @io.makeImeDefault);
% lopts = struct('postLoadFcn', nan);
popts = struct();
% popts = struct('plotdir', '', 'doSave', false, 'doTimestampFolder', false);

dts = io.getAllowedDates();
es = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
%     popts.plotdir = ['plots/allNew/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    figure; plot.barByHypQuick(D.score(2:end), 'errOfMeans');
    figure; plot.barByHypQuick(D.score(2:end), 'histErr');
%     es{ii} = [D.score(2:end).errOfMeans];
    continue;

    ps = [50 100 150 200 250];
    Zs = cell(numel(ps),1); nms = cell(size(Zs));
    for jj = 1:numel(ps)
        custopts = struct('thetaTol', nan, 'minDist', nan, 'kNN', ps(jj));
        Zs{jj} = pred.sameCloudFit(D, custopts);
        nms{jj} = ['cloud-' num2str(ps(jj))];
    end
    D = pred.addAndScoreHypothesis(D, Zs, nms);
    
%     [~, inds] = sort({D.hyps.name});
    inds = 2:numel(D.hyps);
    figure;
    subplot(2,1,1); plot.barByHypQuick(D.score(inds), 'errOfMeans');
    subplot(2,1,2); plot.barByHypQuick(D.score(inds), 'covError');
%     subplot(2,2,3); plot.barByHypQuick(E.score(inds1), 'errOfMeans');
%     subplot(2,2,4); plot.barByHypQuick(E.score(inds1), 'covError');
%     title(D.datestr);
%     figure;
%     subplot(2,2,1); plot.errorByKin(D.score(inds), 'errOfMeansByKin');
%     subplot(2,2,2); plot.errorByKin(D.score(inds), 'covErrorByKin');
%     subplot(2,2,3); plot.errorByKin(E.score(inds1), 'errOfMeansByKin');
%     subplot(2,2,4); plot.errorByKin(E.score(inds1), 'covErrorByKin');
    title(D.datestr);
    
end

%%

vs = {es11, es12, es22, es21};
barNms = {'th', 'th, fit=thAct', 'thAct', 'thAct, fit=th'};
vs = {esBase, esIme};
barNms = {'base', 'ime'};

plot.init;
c = 0;
for ii = 1:4%numel(es11{1})
    c = c + 1;
    vals = cell(numel(vs),1);    
    subplot(1, 4, c); hold on;
    for jj = 1:numel(vs)        
        vals{jj} = cellfun(@(x) x(ii), vs{jj});
        plot(vals{jj}, '-o', 'LineWidth', 3);
    end    
%     xs = vals{xind};
%     ys = vals{yind};
%     plot(ys./xs);
%     xlabel(barNms{xind});
%     ylabel(barNms{yind});
    legend(barNms);
    legend boxoff;
    title(D.score(ii+1).name);
    ylim([0 2]);
end

