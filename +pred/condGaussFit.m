function Z = condGaussFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'byGrps', false, ...
        'doSample', true, 'obeyBounds', true, 'boundsType', 'marginal', ...
        'grpName', 'thetaGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    [nt, nn] = size(B2.latents);
    nNull = size(NB2,2);    
    
    % fit model on B1
    YR = B1.latents*RB2;
    YN = B1.latents*NB2;
    mu = mean([YR YN]);
    S = cov([YR YN]);
        
    YR2 = B2.latents*RB2;
    ixUnknown = false(nn,1); ixUnknown(end-nNull+1:end) = true;
    Zsamp = nan(nt,nNull);
    
    % for keeping predictions within observed bounds
    isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType);
    d = 0;
    
    Zr = B2.latents*(RB2*RB2');
    if ~opts.byGrps
        % predict given YR2
        [mubar, sigbar] = tools.condGaussMean(mu, S, ixUnknown);        
        for t = 1:nt
            if ~opts.doSample
                Zsamp(t,:) = mubar(YR2(t,:)');
                continue;
            end            
            Zsamp(t,:) = mvnrnd(mubar(YR2(t,:)'), sigbar);
            c = 0;
            while opts.obeyBounds && isOutOfBounds(Zsamp(t,:)*NB2' + ...
                    Zr(t,:)) && c < 10
                Zsamp(t,:) = mvnrnd(mubar(YR2(t,:)'), sigbar);
                c = c + 1;
            end
            if c > 1 && c < 10
                d = d + 1;
            end
        end
    else
        gs1 = B1.(opts.grpName);
        gs2 = B2.(opts.grpName);
        grps = sort(unique(gs2));
        for ii = 1:numel(grps)
            
            % fit model on B1 for this thetaGrp
            ix = grps(ii) == gs1;                       
            R = [YR(ix,:) YN(ix,:)];
            mu = mean(R); S = cov(R);
            [mubar, sigbar] = tools.condGaussMean(mu, S, ixUnknown);
            
            % predict given YR2
            ixc = grps(ii) == gs2;
            ts = 1:nt; ts = ts(ixc);
            for jj = 1:numel(ts)
                if ~opts.doSample
                    Zsamp(ts(jj),:) = mubar(YR2(ts(jj),:)');
                    continue;
                end
                Zsamp(ts(jj),:) = mvnrnd(mubar(YR2(ts(jj),:)'), sigbar);
                if opts.obeyBounds
                    c = 0;
                    while isOutOfBounds(Zsamp(ts(jj),:)*NB2' + Zr(ts(jj),:)) && c < 10
                        Zsamp(ts(jj),:) = mvnrnd(mubar(YR2(ts(jj),:)'), sigbar);
                        c = c + 1;
                    end
                    if c > 1 && c < 10
                        d = d + 1;
                    end
                end
            end
        end
    end
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ' condnrm samples to lie within bounds']);
    end
    Zn = Zsamp*NB2';    
    Z = Zr + Zn;
end
