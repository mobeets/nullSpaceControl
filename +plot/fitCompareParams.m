
ps = struct('MAX_ANGULAR_ERROR', 20, ...
    'MIN_DISTANCE', 50, ...
    'MAX_DISTANCE', 125);
D = cell(4,1);
for ii = 1:4
    D{ii} = fitByDate(ii, true, true, ps);    
end

%%

ps = struct('MAX_ANGULAR_ERROR', 360, ...
    'MIN_DISTANCE', 50, ...
    'MAX_DISTANCE', 125);
F = cell(4,1);
for ii = 1:4
    F{ii} = fitByDate(ii, true, true, ps);    
end

%%

ps = struct('MAX_ANGULAR_ERROR', 360, ...
    'MIN_DISTANCE', 0, ...
    'MAX_DISTANCE', 125);
G = cell(4,1);
for ii = 1:4
    G{ii} = fitByDate(ii, true, true, ps);    
end

%%

ps = struct('MAX_ANGULAR_ERROR', 20, ...
    'MIN_DISTANCE', 0, ...
    'MAX_DISTANCE', 1000);
H = cell(4,1);
for ii = 1:4
    H{ii} = fitByDate(ii, true, true, ps);    
end

%%

scs = nan(4, 4, numel(D{1}.hyps)-1);
for ii = 1:4
    scs(ii,1,:) = [D{ii}.hyps(2:end).errOfMeans];
    scs(ii,2,:) = [F{ii}.hyps(2:end).errOfMeans];
    scs(ii,3,:) = [G{ii}.hyps(2:end).errOfMeans];
    scs(ii,4,:) = [H{ii}.hyps(2:end).errOfMeans];
end

%%

clrs = cbrewer('qual', 'Set2', size(scs,2));
lbls = {'base', 'anyAngErr', 'anyAngErr + noMin', 'no-filter'};
nms = {D{1}.hyps(2:end).name};
figure;
set(gcf, 'color', 'w');
for ii = 1:size(scs,1)
    subplot(2,2,ii); hold on;
    set(gca, 'FontSize', 14);
    box off;
    title(D{ii}.datestr);
    for jj = 1:size(scs,2)
        plot(squeeze(scs(ii,jj,:)), 'Color', clrs(jj,:), ...
            'LineWidth', 3);
    end
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    set(gca, 'XTickLabelRotation', 45);
    if ii == size(scs,1)
        legend(lbls, 'Location', 'SouthWest');
    end
end


