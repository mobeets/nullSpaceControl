% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
    'unconstrained', 'mean shift'};
nms = {'true', 'unconstrained'};
% nms = {'mean shift', 'mean shift prune', 'mean shift og'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps');
lopts = struct('postLoadFcn', @tmp2);
popts = struct();%'plotdir', '', 'doSave', false, 'doTimestampFolder', false);

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.quickLoadByDate(dtstr);
    grps = D.blocks(2).thetaActualGrps;
    median(grpstats(grps, grps, @numel))
    continue;

    hypopts.boundsType = 'marginal';
    hypopts.boundsThresh = inf;
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);

%     ps = [20 30 50 100];
%     ps = 1:10;
%     ps = 0.5:0.5:4;
    ps = [0.25 0.5 1 2 3 4];
    Zs = cell(numel(ps),1);
    nms = cell(size(Zs));
    for jj = 1:numel(ps)
        ps(jj)
        hypopts.boundsType = 'none';
        hypopts.boundsThresh = ps(jj);
        Zs{jj} = pred.uncContFit(D, hypopts);
        nms{jj} = ['unc-' num2str(ps(jj))];
    end
    D = pred.addAndScoreHypothesis(D, Zs, nms);
%     continue;
    
    [~, inds] = sort({D.hyps.name});
%     [~, inds1] = sort({E.hyps.name});
%     inds = 2:numel(D.hyps);
    figure;
    subplot(2,1,1); plot.barByHypQuick(D.score(inds), 'errOfMeans');
    subplot(2,1,2); plot.barByHypQuick(D.score(inds), 'covError');
%     subplot(2,2,3); plot.barByHypQuick(E.score(inds1), 'errOfMeans');
%     subplot(2,2,4); plot.barByHypQuick(E.score(inds1), 'covError');
    title(D.datestr);
    figure;
    subplot(2,1,1); plot.errorByKin(D.score(inds), 'errOfMeansByKin');
    subplot(2,1,2); plot.errorByKin(D.score(inds), 'covErrorByKin');
%     subplot(2,2,3); plot.errorByKin(E.score(inds1), 'errOfMeansByKin');
%     subplot(2,2,4); plot.errorByKin(E.score(inds1), 'covErrorByKin');
    title(D.datestr);
    
end



