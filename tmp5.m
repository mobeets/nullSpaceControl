

% to do: why can't i use thetaGrps?
% to do: smoothed version should look good, AND match what I'm doing

ps = io.setUnfilteredDefaults;
ps.REMOVE_INCORRECTS = true;

dts = {'20120525', '20120601'};
dts = io.getAllowedDates;
flds = {'progress'};
binSz = 700; % if < 50 then it's b/c otherwise we get empty bins
% grpNm = 'targetAngle';
grpNm = 'thetaGrps';
grpTrial = false;

close all;

for ii = 1:numel(dts)
    dtstr = dts{ii};
    D = io.quickLoadByDate(dtstr, ps);
    [lrn, L_bin, L_proj, L_best, L_max, L_raw, ls] = ...
        behav.learningAllTrials(D, flds, grpNm, binSz, grpTrial);
    
    figure;
    subplot(2,2,1); hold on;
    vs = cell2mat(L_max')';
    plot.singleValByGrp(vs(:,1), score.thetaCenters);
%     plot.singleValByGrp(lrn, score.thetaCenters);
    ylabel('learning');
    
    D = fitByDate(dtstr, [], {'habitual'});
    errs = D.hyps(2).errOfMeansByKin;
    subplot(2,2,2); hold on;
    plot.singleValByGrp(errs, score.thetaCenters);
    ylabel('errOfMeans');
    
    subplot(2,2,3); hold on;
    set(gca, 'FontSize', 18);
    clrs = cbrewer('div', 'RdYlGn', numel(L_bin));    
    for jj = 1:numel(L_bin)
        plot(L_bin{jj}, 'Color', clrs(jj,:), 'LineWidth', 4);
    end
    
    plot.subtitle(D.datestr, 'FontSize', 18);
    
end
