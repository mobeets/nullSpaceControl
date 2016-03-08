function [Y,X,N, figs] = allBehaviorsByTrial(D, nms, blockInd, grpName, ...
    binSz, ptsPerBin, collapseTrials, fcns, showExp)
    if nargin < 3
        blockInd = 0;
    end
    if nargin < 4
        grpName = '';
    end
    if nargin < 5
        binSz = 60;
    end
    if nargin < 6
        ptsPerBin = 5;
    end
    if nargin < 7 || isempty(collapseTrials)
        collapseTrials = false(size(nms));
    end
    if nargin < 8
        fcns = [];
    end
    if nargin < 9
        showExp = false;
    end
    
    nflds = numel(nms);
    X = cell(nflds,1);
    Y = cell(nflds,1);
    N = cell(nflds,1);
    for ii = 1:numel(nms)
        if isempty(fcns)
            fcn = nan;
        else
            fcn = fcns{ii};
        end
        [Y{ii}, X{ii}, N{ii}, grps] = tools.behaviorByTrial(D, nms{ii}, ...
            blockInd, grpName, binSz, ptsPerBin, collapseTrials, fcn);
    end
    
    xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
    xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));    
    
    [ngrps, nblks] = size(X{end});
%     if ngrps == 8
%         ncols = 2; nrows = 4;
%     else
%         ncols = floor(sqrt(ngrps)); nrows = ceil(ngrps/ncols);
%     end
    nrows = floor(sqrt(nflds)); ncols = ceil(nflds/nrows);
    clrs = cbrewer('qual', 'Set2', nflds);
    
    figs = struct([]);
    for ii = 1:ngrps
        fig = figure; set(gcf, 'color', 'w');
        for kk = 1:nflds
            if ncols > 1 || nrows > 1
                subplot(ncols, nrows, kk);
            end
            set(gca, 'FontSize', 14); hold on;        
            for jj = 1:nblks
                xc = X{kk}{ii,jj};
                yc = Y{kk}{ii,jj};

                if jj == 1
                    vis = 'on';
                else
                    vis = 'off';
                end
                plot(xc, yc, '-', 'LineWidth', 3, 'Color', clrs(kk,:), ...
                    'HandleVisibility', vis);
                if showExp && ~isempty(xc) && ~isempty(yc)
                    [prms, xs0] = tools.satExpFit(xc, yc);
                    if xs0 >= 0 && xs0 <= range(xc)
                        plot([xs0 + min(xc) xs0 + min(xc)], ylim, '--', ...
                            'Color', clrs(kk,:), 'HandleVisibility', 'off');
                    end
                    plot(xc, tools.satExp(xc - min(xc), prms), ...
                        'Color', clrs(kk,:), 'HandleVisibility', 'off');
                end
            end
            plot([xs1 xs1], ylim, '-', 'Color', [0.5 0.5 0.5], ...
                'LineWidth', 1, 'HandleVisibility', 'off');
            plot([xs2 xs2], ylim, '-', 'Color', [0.5 0.5 0.5], ...
                'LineWidth', 1, 'HandleVisibility', 'off');
            ylabel(nms{kk});
        end
        xlabel('trial index');        
        ttl = D.datestr;
        if ngrps > 1
            ttl = [ttl ', ' grpName '=' num2str(grps(ii))];
        end
        plot.subtitle(ttl);
        xlim([0 max(D.trials.trial_index)]);
        clear v;
        v.fig = fig;
        v.name = ttl;
        figs = [figs v];
    end    

end
