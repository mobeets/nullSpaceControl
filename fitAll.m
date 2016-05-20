% clrW = [200 200 200];
% clrG = [112 191 65];
% clrY = [255 211 40];
% clrO = [243 144 25];
% clrs = [clrW; 0.85*clrG; clrG; 0.9*clrO; 0.9*clrY; clrY; clrO]/255;

% nms = {'true', 'zero', 'cloud-hab', 'habitual', 'mean shift', 'cloud-raw'};
nms = {'true', 'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
    'unconstrained', 'mean shift'};
% nms = {'mean shift', 'mean shift prune', 'mean shift og'};
% nms = {'zero', 'habitual', 'cloud-hab', 'cloud-raw', ...
%         'unconstrained', 'minimum', 'baseline'};

% hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16');
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualImeGrps16');
lopts = struct('postLoadFcn', @tmp2);
popts = struct('plotdir', '', 'doSave', true, ...
    'doTimestampFolder', false, 'errBarNm', '');

dts = io.getAllowedDates();
for ii = 4%1:numel(dts)
    dtstr = dts{ii}
    popts.plotdir = fullfile('plots', 'allFineGrid_ime', dtstr);
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
%     close all;
%     E = fitByDate(dtstr, [], nms, popts, struct('postLoadFcn', @tmp2), hypopts);
% 
% %     ps = [0.1 0.2 0.3 0.4 0.5 0.6 0.7];
%     ps = [20 50 100 200 300];
%     for kk = 1:(hypopts.nBoots+1)
%         for jj = 1:numel(ps)
%             copts = struct('thetaTol', nan, 'minDist', nan, 'kNN', ps(jj));
%             Z = pred.sameCloudFit(D, copts);
%             D = pred.addAndScoreHypothesis(D, Z, ['cloud-' num2str(ps(jj))]);
%             Z = pred.sameCloudFit(E, copts);
%             E = pred.addAndScoreHypothesis(E, Z, ['cloud-' num2str(ps(jj))]);
%         end
%     end
%     
%     [~, inds] = sort({D.hyps.name});
% %     inds = 2:numel(D.hyps);
%     figure;
%     subplot(2,2,1); plot.barByHypQuick(D, D.hyps(inds), 'errOfMeans', 'se');
%     subplot(2,2,2); plot.barByHypQuick(D, D.hyps(inds), 'covError', 'se');
%     subplot(2,2,3); plot.barByHypQuick(E, E.hyps(inds), 'errOfMeans', 'se');
%     subplot(2,2,4); plot.barByHypQuick(E, E.hyps(inds), 'covError', 'se');
% %     figure;
% %     subplot(2,1,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
% %     subplot(2,1,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');
% %     subplot(2,2,3); plot.errorByKin(E.hyps(inds), 'errOfMeansByKin', [], 'se');
% %     subplot(2,2,4); plot.errorByKin(E.hyps(inds), 'covErrorByKin', [], 'se');
%     title(D.datestr);
    
end



