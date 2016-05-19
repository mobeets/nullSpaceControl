function D = addHistogramError(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('scoreGrpNm', 'thetaGrps', ...
        'decoderNm', 'fDecoder', 'baseHypNm', 'observed');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    H = pred.getHyp(D, opts.baseHypNm);
    if ~isequal(H, D.hyps(1)) % assumes first hyp is baseHyp
        error(['"' opts.baseHypNm '" must be first hypothesis.']);
    end
    lfcn = @(y,yh) sum((y-yh).^2);    

    % add marginal histograms
    gs = D.blocks(2).(opts.scoreGrpNm);
    NB = D.blocks(2).(opts.decoderNm).NulM2;
    Zs = cell(numel(D.hyps),1);
    for ii = 1:numel(D.hyps)
        Y = D.hyps(ii).latents*NB;
        if ii == 1
            [Zs{ii}, Xs, grps] = tools.marginalDist(Y, gs);
        else
            Zs{ii} = tools.marginalDist(Y, gs, [], Xs);
        end
        D.hyps(ii).marginalHistograms = Zs{ii};
        D.hyps(ii).marginalHistograms_Xs = Xs;
        D.hyps(ii).marginalHistograms_grps = grps;
    end

    % calculate histogram error
    nitems = numel(Zs);
    ngrps = numel(Zs{1});
    ncols = size(Zs{1}{1},2);
    errs = nan(ngrps, ncols, nitems-1);
    for ii = 1:ngrps
        for jj = 1:ncols
            for kk = 2:nitems % items
                Z0 = Zs{1}{ii}(:,jj);
                Z = Zs{kk}{ii}(:,jj);
                errs(ii,jj,kk-1) = lfcn(Z0, Z);
            end
        end
    end
    
    % add to hyps
    for ii = 1:numel(D.hyps)
        if ii == 1
            err = zeros(size(errs(:,:,1)));
        else
            err = errs(:,:,ii-1);
        end        
        D.hyps(ii).histErrByKinByCol = err;
        D.hyps(ii).histErrByKin = sum(err,2);
        D.hyps(ii).histErrByCol = sum(err,1)';
        D.hyps(ii).histErr = sum(err(:));
    end
end
