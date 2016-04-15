
% close all;
dts = io.getAllowedDates();
opts = struct('showMu', true, 'showPts', true, 'doNull', true, ...
    'doColor', true, 'D', [], 'blockInd', 2, 'grpName', 'thetaGrps', ...
    'mapInd', 2);
behavNm = 'trial_length';
% behavNm = 'progress';
flipSign = true;

opts.v = [];

for ii = 1%1:numel(dts)
    D = io.quickLoadByDate(dts{ii});
    opts.D = D;
    
    figure;
    [~,v] = plot.visualize3d(dts{ii}, opts);
    
%     [prms, grps] = tools.quickBehavior(D, behavNm, opts.grpName);
%     D = io.quickLoadByDate(dts{ii}, struct('START_SHUFFLE', nan));
%     bnms = {'lrn', 'tau', 'yDiff', 'yDiffPct', 'yStart', 'yEnd', 'xThresh'};
% 	figure; plot.quickBehavior(D, behavNm, opts.grpName);
%     continue;
    D = fitByDate(dts{ii}, [], {'condnrmkin'});
    
    figure;
    subplot(2,2,1); hold on;
    plot.singleValByGrp([], [], D, @(Y) det(cov(Y)), opts);
    ylabel('det(cov(Y))');
    subplot(2,2,2); hold on;
    plot.singleValByGrp([], [], D, @(Y) mean(sqrt(sum(Y.^2,2))), opts);
    ylabel('mean(norm(Y))');
    subplot(2,2,3); hold on;
    plot.errorByKin(D.hyps(2:end), 'errOfMeansByKin');
    subplot(2,2,4); hold on;
    D = io.quickLoadByDate(dts{ii}, struct('START_SHUFFLE', nan));
    bnms = {'lrn', 'tau', 'yDiff', 'yStart', 'yEnd', 'xThresh'};
%     bnms = {'tau', 'lrn'};
    plot.quickBehavior(D, behavNm, opts.grpName, bnms, flipSign);
    plot.subtitle(D.datestr, 'FontSize', 18);
end
