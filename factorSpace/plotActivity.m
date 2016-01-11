function plotStructure = plotActivity(latents, theta, intuitiveBasis, shuffleBasis, figureName)

if nargin==4
    figureName = [];
end

TOGETHER = false; % plot intuitiveBasis and shuffleBasis next to each other
ONLY_SHUFFLE = true;
ONLY_NULL = true;

PLOT_INDIVIDUALLY = false;

if ONLY_NULL
    assert(ONLY_SHUFFLE && ~TOGETHER) % other cases not supported yet
end

if TOGETHER
    intuitivePlotIdxs = [1 2 5 6 9 10 13 14 17 18];
    shufflePlotIdxs = [3 4 7 8 11 12 15 16 19 20];
    r = 5;
    c = 4;
else
    intuitivePlotIdxs = 1:10;
    shufflePlotIdxs = 1:10;
    r = 5;
    c = 2;
end

idxs = {1:2, 3:4, 5:6, 7:8, 9:10, 11:12, 14:15, 16:17};

plottedVals = cell(c,r);

figure('Name',figureName,'NumberTitle','off');
if ~ONLY_SHUFFLE
    % Plot on intuitive axes
    for dim = 1:10
        idx = intuitivePlotIdxs(dim);
        subplot(r,c,idx)
        plottedVals{idx} = plotActivityPanel(latents, theta, intuitiveBasis(:,dim), ONLY_SHUFFLE);
    end
    
    
    if ~TOGETHER
        figure;
    end
end
% Plot on shuffle axes
for dim = 1:10
    if ONLY_NULL && dim <= 2
        continue;
    end
    
    if ONLY_NULL
        offset = 2;
        ro = 1; % row offset
    else
        offset = 0;
        ro = 0;
    end        
    
    if ~PLOT_INDIVIDUALLY
        subplot(3,6, idxs{dim-2})
    else
        figure;
    end
    idx = shufflePlotIdxs(dim);
    plottedVals{idx} = plotActivityPanel(latents, theta, ...
        shuffleBasis(:,dim), ONLY_SHUFFLE);
    
    if ~PLOT_INDIVIDUALLY
        text(3.3,2.75,['n_' num2str(dim-2) '^T \mu'], 'Fontsize', 16, 'FontWeight','bold', 'HorizontalAlignment','center')%['\textbf{n}_' num2str(dim-2) '^\intercal\boldsymbol{\mu}'],'Fontsize',16)
    else
        set(gca,'XTickLabel','')
        save_figure(['paper/predictedSticks/' figureName '_' num2str(dim-offset) '_big'], 4, 6)
        save_figure(['paper/predictedSticks/' figureName '_' num2str(dim-offset) '_small'], 2, 3)
    end
end
set(gcf,'Position',[304 676 1098 420])

if ~TOGETHER && ~ONLY_SHUFFLE
    plottedVals = nan;
    warning('plotted vals not supported when not plotting together')
end

plottedVals = plottedVals';

plotStructure = struct();
plotStructure.vals = plottedVals;
plotStructure.name = figureName;