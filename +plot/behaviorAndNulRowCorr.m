function behaviorAndNulRowCorr(D, blockInd, mapInd, grpName, doScatter)
    if nargin < 2 || isnan(blockInd)
        blockInd = 0;
    end
    if nargin < 3 || isnan(mapInd)
        mapInd = 2;
    end
    if nargin < 4
        grpName = '';
    end
    if nargin < 5
        doScatter = false;
    end
    if blockInd > 0
        B = D.blocks(blockInd);
    else
        B = D.trials;
    end
    
    % map
    dec = D.blocks(mapInd).fDecoder;
    NB = dec.NulM2;
    RB = dec.RowM2;
    
    % activity
    Y = B.latents;
    YR = Y*NB;
    YN = Y*RB;
    
    if ~isempty(grpName)
        gs = B.(grpName);
        grps = sort(unique(gs));
        ncols = 4; nrows = 2;
    else
        gs = true(size(B.progress));
        grps = 1;
        ncols = 1; nrows = 1;
    end
    
%     nms = {'progress', 'isCorrect', 'trial_length', 'angError'};
%     zs = [100, 100, 100, 100];
    nms = {'progress', 'angError'};
    zs = [100 100];
    
    Z = cell(numel(nms),1);
    for ii = 1:numel(nms)
        Z{ii} = B.(nms{ii});
    end    
    cs = cbrewer('qual', 'Set1', numel(zs)+2);
    clr1 = cs(1,:);
    clr2 = cs(2,:);
    cs = cs(3:end,:);
    
    set(gcf, 'color', 'w');
    xs = B.trial_index;
    xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
    xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));
    nTrsPerBin = 16;
    for ii = 1:numel(grps)
        subplot(ncols, nrows, ii); set(gca, 'FontSize', 14);
        hold on;
        
        for kk = 1:3
            if kk == 1
                ib = xs < xs1;
            elseif kk == 2
                ib = xs >= xs1 & xs < xs2;
            else
                ib = xs >= xs2;
            end
            if sum(ib) == 0
                continue;
            end
        
            ix = ib & grps(ii) == gs;
            if sum(ix) == 0
                continue;
            end
            YNc = YN(ix,:);
            YRc = YR(ix,:);
            xsc = xs(ix);
            xsa = sort(unique(xsc));
            xsb = min(xsa) + (0:nTrsPerBin:range(xsa));
            if max(xsa) ~= max(xsb)
                xsb = [xsb max(xsb)];
            end
            
            % calculate max corr between YR and YN
            rrs = nan(numel(xsb)-1, 2);
            yscs = nan(numel(xsb)-1, numel(Z));
            for jj = 1:numel(xsb)-1
                iy = xsc >= xsb(jj) & xsc <= xsb(jj+1);
                if sum(iy) <= 20
                    continue;
                end
                for ll = 1:numel(Z)
                    ysc = double(Z{ll});
                    ysc = ysc(ix);
                    yscs(jj,ll) = nanmean(ysc(iy));
                end
                [~,~,rrs(jj,:),~,~] = canoncorr(YRc(iy,:), YNc(iy,:));                
            end
            
%             % smooth behavior
%             for jj = 1:numel(Z)
%                 ysc = double(Z{jj});
%                 ysc = ysc(ix);
%                 if ~isnan(zs(jj))
%                     ysc = smooth(xsc, ysc, zs(jj));
%                 end
%                 ysc = ysc./max(abs(ysc)); % normalize
%                 plot(xsc, ysc, 'Color', cs(jj,:));
%             end
            
            for jj = 1:numel(Z)
                ysc = yscs(:,jj);                
                if isempty(ysc)
                    continue;
                end
                iz = ~isnan(rrs(:,1)) & ~isnan(ysc);
                [A,B,~,~,~] = canoncorr(rrs(iz,1), ysc(iz));
                ysc = (ysc - nanmean(ysc))*B/A + nanmean(rrs(:,1));
%                 ysc = ysc./max(abs(ysc)); % normalize
                if doScatter
                    plot(rrs(:,1), ysc, 'ko', 'MarkerFaceColor', cs(jj,:));
                else
                    plot(xsb(1:end-1), ysc, 'Color', cs(jj,:), 'LineWidth', 3);
                end
            end            
            if ~doScatter
                plot(xsb(1:end-1), rrs(:,1), '-', 'Color', clr1, 'LineWidth', 3);
                plot([xs1 xs1], ylim, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
                plot([xs2 xs2], ylim, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
            else
                plot([min(rrs(:,1)) max(rrs(:,1))], ...
                    [min(rrs(:,1)) max(rrs(:,1))], 'k--');
            end
        end
    end
    if ~doScatter
        xlabel('trial index');
    else
        xlabel('CCA(YN, YR)');
    end
    ylabel('value');

end
