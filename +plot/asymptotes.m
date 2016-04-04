
dts = io.getDates();
grpName = 'targetAngle';
fnm = fullfile('data', ['behavioralAsymptotes_' grpName '.mat']);
fnm0 = fullfile('data', ['behavioralAsymptotes_.mat']);
ths = load(fnm);
% nms = ths.nms;
nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};
ths = ths.ths;
ths0 = load(fnm0);
ths0 = ths0.ths;

%%

behav = {'progress', 'trial_length'};
% behav = {'trial_length'};
behavInds = find(ismember(nms, behav));
scsAll = {};

close all;
for jj = 1:numel(ths)
%     if ~strcmp(dts{jj}(4), '3')
%         continue;
%     end
    
    th = ths{jj};
    th0 = ths0{jj};
    clrs = cbrewer('qual', 'Set1', size(th,2));    
    
    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);
    
    % plot bars
    wdth = 0.8;
    for ii = behavInds % 1:size(th,2)
        bar(score.thetaCenters, th(:,ii), wdth, ...
            'EdgeColor', clrs(ii,:), 'FaceColor', clrs(ii,:));
        wdth = wdth - 0.1;
    end    
    
    % plot global asymptote
    for ii = behavInds
        if ~isnan(th0(ii))
            plot(xlim, [th0(ii) th0(ii)], '--', 'Color', clrs(ii,:), ...
                'LineWidth', 3);
        end
    end
    
    legend(nms{behavInds}, 'Location', 'BestOutside');
    ax = gca;
    ax.XTick = score.thetaCenters;
    ax.XTickLabel = arrayfun(@(ii) num2str(ax.XTick(ii)), 1:numel(ax.XTick), 'uni', 0);
    xlabel('\theta');
    ylabel('behavioral asymptote (trial #)');
    title(dts{jj});
end

%%

hyps = {'cloud-hab', 'habitual', 'volitional', 'condnrm'};
dts0 = io.getAllowedDates();
scsAll = cell(numel(dts0),1);
scsAllCov = cell(numel(dts0),1);
for ii = 1:numel(dts0)
    D = fitByDate(dts0{ii}, [], hyps);
%     scsAll{ii} = cell2mat({D.hyps.errOfMeansByKin}');
    scsAllCov{ii} = cell2mat({D.hyps.covErrorByKin})';x
end

%%

close all;
hyps = {D.hyps.name}; hyps = hyps(2:end);
for kk = 1:numel(hyps)
    scs = nan(numel(dts0), size(scsAllCov{1},2));
    for jj = 1:numel(dts0)
        scs(jj,:) = scsAllCov{jj}(kk,:);
    end
    
    figure; set(gcf, 'color', 'w');
    for jj = 1:numel(nms)
        ix = ismember(dts, io.getAllowedDates);
        inds = 1:numel(dts); inds = inds(ix);
        ts = nan(size(scs));
        for ii = 1:numel(inds)
            th = ths{inds(ii)};
            th = th(:,jj);
            ts(ii,:) = th;
        end

        subplot(2, 3, jj);
        hold on; set(gca, 'FontSize', 14);
        clrs = cbrewer('qual', 'Set2', size(scs,1));
        for ii = 1:size(scs,1)
            xs = ts(ii,:);
            ys = scs(ii,:);
            [~,ix] = sort(xs);
            xs = xs(ix);
            ys = ys(ix);
    %         xs = xs./nanmean(xs);
    %         ys = ys./nanmean(ys);
            plot(xs, ys, '-k');
            plot(xs, ys, 'o', 'Color', clrs(ii,:), ...
                'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 5);            
        end
        xlabel([nms{jj} ' asymptote']);
        ylabel([hyps{kk} ' errCov']);
    end
end
