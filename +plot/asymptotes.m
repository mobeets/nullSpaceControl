
grpName = 'targetAngle';
fnm = fullfile('data', ['behavioralAsymptotes_' grpName '.mat']);
fnm0 = fullfile('data', 'behavioralAsymptotes_.mat');
ths = load(fnm); dts = ths.dts; ths = ths.ths;
ths0 = load(fnm0); ths0 = ths0.ths;
nms = {'progress', 'progressOrth', 'angErrorAbs', 'angError', ...
    'trial_length', 'isCorrect'};
clrs = cbrewer('qual', 'Set1', numel(nms));
grps = score.thetaCenters;

%%

behav = {'progress', 'trial_length'};
behavInds = find(ismember(nms, behav));

for ii = 1%:numel(ths)
    th = ths{ii};
    th0 = ths0{ii};
    plot.init;
    
    % plot bars
    wdth = 0.8;
    for jj = behavInds
        bar(grps, th(:,jj), wdth, ...
            'EdgeColor', clrs(jj,:), 'FaceColor', clrs(jj,:));
        wdth = wdth - 0.1;
    end    
    
    % plot global asymptote
    for jj = behavInds
        if ~isnan(th0(jj))
            plot(xlim, [th0(jj) th0(jj)], '--', 'Color', clrs(jj,:), ...
                'LineWidth', 3);
        end
    end
    
    legend(nms{behavInds}, 'Location', 'BestOutside');    
    set(gca, 'XTick', grps);
    set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
    xlabel('\theta');
    ylabel('behavioral asymptote (trial #)');
    title(dts{ii});
end
