function Z = condGaussFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'byThetaGrps', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    [nt, nn] = size(B2.latents);
    nNull = size(NB2,2);    
    
    % train
    YR = B1.latents*RB2;
    YN = B1.latents*NB2;
    mu = mean([YR YN]);
    S = cov([YR YN]);
    
    % predict, given YR2
    YR2 = B2.latents*RB2;
    ixUnknown = false(nn,1); ixUnknown(end-nNull+1:end) = true;
    Zsamp = nan(nt,nNull);
    
    if ~opts.byThetaGrps        
        [mubar, sigbar] = tools.condGaussMean(mu, S, ixUnknown);
        for t = 1:nt
            Zsamp(t,:) = mvnrnd(mubar(YR2(t,:)'), sigbar);
        end
    else
        gs1 = B1.thetaGrps;
        gs2 = B2.thetaGrps;
        grps = sort(unique(gs2));
        for ii = 1:numel(grps)
            
            % train model
            ix = grps(ii) == gs1;                       
            R = [YR(ix,:) YN(ix,:)];
            mu = mean(R); S = cov(R);
            [mubar, sigbar] = tools.condGaussMean(mu, S, ixUnknown);
            
            % predict, given YR2
            ixc = grps(ii) == gs2;
            ts = 1:nt; ts = ts(ixc);
            for jj = 1:numel(ts)
                Zsamp(ts(jj),:) = mvnrnd(mubar(YR2(ts(jj),:)'), sigbar);
            end
        end
    end
    Zn = Zsamp*NB2';
    Zr = B2.latents*(RB2*RB2');
    Z = Zr + Zn;
end
