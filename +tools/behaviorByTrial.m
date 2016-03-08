function [Ys, Xs, Ns, grps] = behaviorByTrial(D, fldNm, blockInd, grpName, ...
    binSz, ptsPerBin, collapseTrial, reduceFcn, slidingBins)
    if nargin < 2
        fldNm = 'progress';
    end
    if nargin < 3 || isnan(blockInd)
        blockInd = 0;
    end
    if nargin < 4
        grpName = '';
    end
    if nargin < 5
        binSz = 32; % # of trials per bin
    end
    if nargin < 6
        ptsPerBin = 30;
    end
    if nargin < 7
        collapseTrial = false; % ignore multiple entries per trial
    end
    if nargin < 8 || ~isa(reduceFcn, 'function_handle')
        reduceFcn = @(y) nanmean(y);
    end
    if nargin < 9
        slidingBins = true;
    end
    
    if blockInd > 0
        B = D.blocks(blockInd);
    else
        B = D.trials;
    end
    xs = B.trial_index;
    xs1 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'first'));
    xs2 = D.trials.trial_index(find(D.trials.block_index == 2, 1, 'last'));
    if isa(fldNm, 'char')
        Y = double(B.(fldNm));
    else
        % collect multiple fields, to be handled by reduceFcn
        Y = [];
        YA = cell(numel(fldNm),1);
        for ii = 1:numel(fldNm)
            YA{ii} = double(B.(fldNm{ii}));
        end
    end
    
    if ~isempty(grpName)
        gs = B.(grpName);
        grps = sort(unique(gs(~isnan(gs))));
    else
        gs = true(size(B.latents,1), 1);
        grps = 1;
    end
    
    nblks = 3;
    Ys = cell(numel(grps), nblks);
    Xs = cell(numel(grps), nblks);
    Ns = cell(numel(grps), nblks);
    for ii = 1:numel(grps)
        for kk = 1:nblks            
            if kk == 1
                ib = xs < xs1;
            elseif kk == 2
                ib = xs >= xs1 & xs < xs2;
            else
                ib = xs >= xs2;
            end
            ig = grps(ii) == gs;
            ix = ib & ig;
            if sum(ix) == 0
                continue;
            end

            % define trial bins
            xsc = xs(ix);
            if ~isempty(Y)
                ysc = Y(ix,:);
                ysca = {};
            else
                ysca = cell(size(YA));
                for mm = 1:numel(fldNm)
                    ysca{mm} = YA{mm}(ix,:);
                end
            end
            xsa = sort(unique(xsc));
            if slidingBins
                xsb = xsa(xsa < max(xsa)-binSz);
            else
                xsb = min(xsa) + (0:binSz:range(xsa));
                if max(xsa) ~= max(xsb)
                    xsb = [xsb max(xsb)];
                end
                xsb = xsb';
            end
            if collapseTrial
%                 assert(~isempty(Y));
                if ~isempty(Y)
                    ysa = nan(size(xsa,1), size(ysc,2));
                    for jj = 1:numel(xsa)
                        ysa(jj,:) = nanmean(ysc(xsc == xsa(jj),:));
                    end
                    ysc = ysa;
                else
                    yscb = cell(size(ysca));
                    for mm = 1:numel(ysca)
                        yscb{mm} = nan(size(xsa,1), size(ysca{mm},2));
                    end
                    for jj = 1:numel(xsa)
                        if isempty(Y)
                            for mm = 1:numel(ysca)
                                yt = ysca{mm};
                                yscb{mm}(jj,:) = nanmean(yt(xsc==xsa(jj),:));
                            end
                        end
                    end
                    ysca = yscb;
                end                
                xsc = xsa;                
            end

            % mean of current Y per bin
            ysb = nan(numel(xsb)-1, 1);
            nsb = nan(numel(xsb)-1, 1);
            for jj = 1:numel(xsb)-1
                if slidingBins
                    it = xsc >= xsb(jj) & xsc <= xsb(jj)+binSz;
                else
                    it = xsc >= xsb(jj) & xsc <= xsb(jj+1);
                end
                if sum(it) < ptsPerBin
                    continue;
                end                
                if ~isempty(Y)
                    nNonNan = sum(~any(isnan(ysc(it,:)),2));
                    if nNonNan < ptsPerBin
                        continue;
                    end
                    ysb(jj) = reduceFcn(ysc(it,:));
                else
                    yscb = cell(size(ysca));
                    ixs = nan(size(ysca,1), sum(it));
                    for mm = 1:numel(fldNm)
                        yscb{mm} = ysca{mm}(it,:);
                        ixs(mm,:) = ~any(isnan(yscb{mm}),2);
                    end
                    nNonNan = sum(prod(ixs));
                    if nNonNan < ptsPerBin
                        continue;
                    end
                    ysb(jj) = reduceFcn(yscb);
                end
                nsb(jj) = nNonNan;
            end
            
            % smooth behavior
%             ysc = smooth(xsc, ysc, smth);
%             ysc = ysc./max(abs(ysc)); % normalize
%             plot(xsc, ysc, 'Color', clr);
            
            Xs{ii,kk} = xsb(1:end-1);
            Ys{ii,kk} = ysb;
            Ns{ii,kk} = nsb;
        end
    end

end
