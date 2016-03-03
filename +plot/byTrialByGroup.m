function byTrialByGroup(D, blockInd, grpName, nms, zs)
    if nargin < 2 || isnan(blockInd)
        blockInd = 0;
    end
    if nargin < 3
        grpName = '';
    end
    if blockInd > 0
        B = D.blocks(blockInd);
    else
        B = D.trials;
    end
    
    if ~isempty(grpName)
        gs = B.(grpName);
        grps = sort(unique(gs));
        ncols = 4; nrows = 2;
    else
        gs = true(size(B.progress));
        grps = 1;
        ncols = 1; nrows = 1;
    end
    xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
    xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));
    xs = B.trial_index;
    
    Z = cell(numel(nms),1);
    for ii = 1:numel(nms)
        Z{ii} = B.(nms{ii});
    end    
    cs = cbrewer('qual', 'Set1', numel(zs));
    
    set(gcf, 'color', 'w');
    for kk = 1:3
        if kk == 1
            ib = xs < xs1;
        elseif kk == 2
            ib = xs >= xs1 & xs < xs2;
        else
            ib = xs >= xs2;
        end
        for ii = 1:numel(grps)
            subplot(ncols, nrows, ii); set(gca, 'FontSize', 14);
            hold on;
            ix = ib & (gs == grps(ii));
            for jj = 1:numel(Z)
                yc = double(Z{jj});
                iy = ~isnan(yc);
                if ~isnan(zs(jj))
                    yc = smooth(xs(ix&iy), yc(ix&iy), zs(jj));
                else
                    yc = yc(ix&iy);
                end
                yc = yc./max(abs(yc)); % normalize
                plot(xs(ix&iy), yc, 'Color', cs(jj,:));
            end
        end
        plot([xs1 xs1], ylim, '-', 'Color', [0.5 0.5 0.5]);
        plot([xs2 xs2], ylim, '-', 'Color', [0.5 0.5 0.5]);
    end    
    xlabel('trial index');
    ylabel('value');

end
