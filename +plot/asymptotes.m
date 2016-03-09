
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

close all;
for jj = 1:numel(ths)
    if ~strcmp(dts{jj}(4), '3')
        continue;
    end
    
    th = ths{jj};
    th0 = ths0{jj};
    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);

    clrs = cbrewer('qual', 'Set1', size(th,2));
    
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
