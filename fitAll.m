
nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
    'unconstrained', 'mean shift'};
nms = {'true', 'cloud-raw'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps');
lopts = struct('postLoadFcn', @io.makeImeDefault);
popts = struct();
% popts = struct('plotdir', '', 'doSave', false, 'doTimestampFolder', false);

dts = io.getAllowedDates();
for ii = 3%1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);

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
