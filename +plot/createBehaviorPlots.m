function [Y,X,N,fits,popts] = createBehaviorPlots(D, blockInd, ...
    grpName, nms, binSz, ptsPerBin, collapseTrials, fcns, fcnNms, ...
    popts, hopts)
    if nargin < 10 || isepmty(popts)
        popts = struct();
    end
    if nargin < 11 || isepmty(hopts)
        hopts = struct();
    end
    assert(isa(popts, 'struct'));
    defopts = struct('doSave', false, 'fignm', '', ...
        'plotdir', fullfile('plots', 'behaviorByTrial'), 'askedOnce', false);
    popts = tools.setDefaultOptsWhenNecessary(popts, defopts);
    
    assert(isa(hopts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder');
    hopts = tools.setDefaultOptsWhenNecessary(hopts, defopts);

    if any(strcmp(nms, 'YBmin')) || any(strcmp(nms, 'YBavg')) || ...
            any(strcmp(nms, 'YBavgNorm'))
        [D.trials.YBmin, D.trials.YBavg, D.trials.YBavgNorm] = ...
            addBaselineByGroup(D, grpName);
    end
    D.trials.progressOrth = addProgressOrth(D);
    D.trials.angErrorAbs = abs(D.trials.angError);
    D.trials.Y1 = D.trials.latents(:,1);
    D.trials.Y2 = D.trials.latents(:,2);
    D = addLatentsByBlock(D, 1, hopts);
    D = addLatentsByBlock(D, 2, hopts);
    
    D.trials.YN = D.trials.YN1;
    D.trials.YR = D.trials.YR1;
    ib2 = D.trials.block_index == 2;
    D.trials.YN(ib2,:) = D.trials.YN2(ib2,:);
    D.trials.YR(ib2,:) = D.trials.YR2(ib2,:);

    [Y,X,N,fits,figs] = plot.allBehaviorsByTrial(D, nms, blockInd, ...
        grpName, binSz, ptsPerBin, collapseTrials, fcns, fcnNms, true);
    
    for jj = 1:numel(figs)
        fnm = fullfile(popts.plotdir, [figs(jj).name popts.fignm '.png']);
        [popts.doSave, popts.askedOnce] = plot.checkSafeToSave(...
            popts.plotdir, fnm, popts.doSave, popts.askedOnce);
        if popts.doSave
            saveas(figs(jj).fig, fnm, 'png');
        end
    end
%     
%     if opts.doSave
%         if ~exist(opts.outdir, 'dir')
%             mkdir(opts.outdir);
%         end
%         for jj = 1:numel(figs)
%             fnm = fullfile(opts.outdir, [figs(jj).name opts.nm]);
%             if exist([fnm '.png'], 'file') && ~opts.askedOnce
%                 resp = input(['Similar files in "' opts.outdir ...
%                     '" already exist. Continue? '], 's');
%                 if ~strcmpi(resp(1), 'y')
%                     error('No save.');
%                 else
%                     opts.askedOnce = true;
%                 end
%             end
%             saveas(figs(jj).fig, fnm, 'png');
%         end
%     end
end

function D = addLatentsByBlock(D, ind, hopts)
    Y = D.trials.latents;
    B = D.blocks(ind);
    NB = B.(hopts.decoderNm).NulM2;
    RB = B.(hopts.decoderNm).RowM2;
    YN = Y*NB;
    YR = Y*RB;
    D.trials.(['YN' num2str(ind)]) = YN;
    D.trials.(['YR' num2str(ind)]) = YR;
%     [~,~,v] = svd(YN); YN2 = YN*v;
%     D.trials.(['YNr' num2str(ind)]) = YN2(:,1);
end

function progressOrth = addProgressOrth(D)

    progressOrth = nan(size(D.trials.progress));
    for t = 1:numel(D.trials.progress)
        vec2trg = D.trials.vec2target(t,:);
        vec2trgOrth(1) = vec2trg(2);
        vec2trgOrth(2) = -vec2trg(1);
        movVec = D.trials.movementVector(t,:);
        progressOrth(t) = -(movVec*vec2trgOrth'/norm(vec2trg));
    end
end

function [YBmin, YBavg, YBavgNorm] = addBaselineByGroup(D, grpName)

    B1 = D.blocks(1);
    Y1 = B1.latents;
    if ~isempty(grpName)
        gs = B1.(grpName);
        gsa = D.trials.(grpName);
    else
        gs = true(size(Y1,1),1);
        gsa = true(size(D.trials.spd,1),1);
    end
    grps = sort(unique(gs(~isnan(gs))));

    y1 = cell(numel(grps), 1);
    for jj = 1:numel(grps)
        ig = grps(jj) == gs;
        y1{jj} = Y1(ig,:);
    end
    
    for t = 1:numel(D.trials.progress)
        yt = D.trials.latents(t,:);
        ind = find(grps == gsa(t));
        if ~isnan(ind)
            yc = y1{ind};
            ya = repmat(yt, size(yc,1), 1);
            
            [~,ix] = min(nanmean((ya - yc).^2,2));
            YBmin(t,:) = norm(ya(ix,:) - yc(ix,:));
            YBavg(t,:) = yt - mean(yc);
            YBavgNorm(t,:) = norm(yt - mean(yc));
        end
    end
end
