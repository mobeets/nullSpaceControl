
dts = io.getAllowedDates();

% grpNm = 'targetAngle';
grpNm = 'thetaGrps';
% grpNm = 'thetaActualGrps';

% nms = {'habitual', 'cloud-hab', 'volitional', 'unconstrained'};
nms = {'cloud-hab', 'habitual'};
hopts = struct('decoderNm', 'fDecoder', 'scoreGrpNm', grpNm);

for ii = 1:numel(dts)
    dtstr = dts{ii};
    figure;
    subplot(2,2,1);
    behav.simpleBehavior(dtstr, 'progress', grpNm);
    subplot(2,2,2);
    behav.simpleBehavior(dtstr, 'trial_length', grpNm);
    subplot(2,2,3);
    behav.simpleBehavior(dtstr, 'isCorrect', grpNm);
    subplot(2,2,4);
    D = fitByDate(dtstr, [], nms, [], [], hopts);    
%     plot.allErrorByKin(D, D.hyps(2:end));
    vs = D.hyps(2).errOfMeansByKin;
    vs1 = D.hyps(3).errOfMeansByKin;
    vs = (vs - vs1)./vs;
    plot.singleValByGrp(vs, score.thetaCenters);
    ylabel('error in mean');
end

%%

dts = io.getAllowedDates();
ths = score.thetaCenters;
% thetaGrps:
% least = [270 315; 135 180; 135 180; 270 315; 0 45];
% most = [45 90; 45 90; 0 45; 90 45; 180 225];

% thetaActualGrps
least = [270 315; 0 315; 135 180; 180 315; 0 45];
most = [45 90; 45 90; 0 45; 90 135; 135 180];

lst_errs = nan(numel(dts),2);
mst_errs = nan(numel(dts),2);

for ii = 1:numel(dts)
    dtstr = dts{ii};
    D = fitByDate(dtstr, [], {'cloud-hab'}, [], [], hopts);
    
    lst = least(ii,:);
    mst = most(ii,:);
    e1 = D.hyps(2).errOfMeansByKin(ismember(ths, lst));
    e2 = D.hyps(2).errOfMeansByKin(ismember(ths, mst));
    
    lst_errs(ii,:) = e1;
    mst_errs(ii,:) = e2;
end

%% now, below: compare when pruning better than habitual

% errMus and errCovs is 5x1 cell of 3x8 arrays of scores:
%   3x8 = true, hab, pruning scores for all 8 thetaGrps
muErr = cat(3, errMus{:});
covErr = cat(3, errCovs{:});

figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 18);
clrs = cbrewer('qual', 'Set1', numel(dts));
msz = 15;
msp = 5;

for ii = 1:numel(dts)
    e1 = lst_errs(ii,:);
    e2 = mst_errs(ii,:);
    st = 'ko';
    if ii > 3
        st = 'ks';
    end
    plot(mean(e1), mean(e2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msz);
    plot(e1(1), e2(1), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(1), e2(2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(2), e2(1), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(2), e2(2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
end
mx1 = max(lst_errs(:)); mx2 = max(mst_errs(:)); mx = max(mx1, mx2);
xlim([0 mx]); ylim(xlim);
plot(xlim, ylim, 'k--');

set(gca, 'XTick', 1:round(mx));
set(gca, 'YTick', 1:round(mx));
axis square;
xlabel('errors for grps with least learning');
ylabel('errors for grps with most learning');

%%


muBest = [270 315; 0 45; 0 270; 45 90; 0 225];
muWorst = [135 180; 270 315; 180 225; 270 315; 270 315];
covBest = [45 90; 45 90; 0 270; 45 90; 0 90];
covWorst = [225 270; 180 270; 180 225; 225 270; 180 225];
ths = score.thetaCenters;
leastLrn = [270 315; 0 315; 135 180; 180 315; 0 45];
mostLrn = [45 90; 45 90; 0 45; 90 135; 135 180];

errVs = muErr;
lst_errs = nan(numel(dts),2);
mst_errs = nan(size(lst_errs));
for ii = 1:numel(dts)
    th1 = leastLrn(ii,:);
    th2 = mostLrn(ii,:);
    eA1 = squeeze(errVs(2, ismember(ths, th1), ii));
    eB1 = squeeze(errVs(3, ismember(ths, th1), ii));
    eA2 = squeeze(errVs(2, ismember(ths, th2), ii));
    eB2 = squeeze(errVs(3, ismember(ths, th2), ii));
    
    lst_errs(ii,:) = eA1 - eB1;
    mst_errs(ii,:) = eA2 - eB2;
end

plot.init;
clrs = cbrewer('qual', 'Set1', numel(dts));
msz = 15;
msp = 5;

for ii = 1:numel(dts)
    e1 = lst_errs(ii,:);
    e2 = mst_errs(ii,:);
    st = 'ko';
    if ii > 3
        st = 'ks';
    end
    plot(mean(e1), mean(e2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msz);
    plot(e1(1), e2(1), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(1), e2(2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(2), e2(1), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
    plot(e1(2), e2(2), st, 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', msp);
end
bnds = tools.getLims([mst_errs(:); lst_errs(:)]); mn = bnds(1); mx = bnds(2);
% mx1 = max(lst_errs(:)); mx2 = max(mst_errs(:)); mx = max(mx1, mx2);
xlim([mn mx]); ylim(xlim);
plot(xlim, ylim, 'k--');

% set(gca, 'XTick', 1:round(mx));
% set(gca, 'YTick', 1:round(mx));
axis square;
xlabel('mean errors for grps with least learning');
ylabel('mean errors for grps with most learning');


