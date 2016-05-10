function rotThetas = rotThetasFromMeanShift(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'grpNm', 'thetaGrps', 'thetaTol', 30);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    
    Y1 = B1.latents;
    YR1 = Y1*RB2;
    YN1 = Y1*NB2;
    YR2 = B2.latents*RB2;
    
    ths1 = B1.(opts.thetaNm);
    ths = B2.(opts.thetaNm);
    gs = B2.(opts.grpNm);
    grps = sort(unique(gs));
    
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    rotThetas = zeros(numel(grps), 1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        mu = mean(YR2(ix,:));
        
        offsets = -50:2.5:50;
        errs = nan(size(offsets));
        for jj = 1:numel(offsets)
            
            if isnan(opts.thetaTol) || isinf(opts.thetaTol)
                ixc = newGroup(ths1, offsets(jj)) == grps(ii);
                mu1 = mean(YR1(ixc,:));
                errs(jj) = norm(mu1 - mu);
                continue;
            end
            
            ths1c = mod(ths1 + offsets(jj), 360);
            ts = 1:nt; ts = ts(ix);
            Yc = nan(numel(ts), size(YR1,2));
            for kk = 1:numel(ts)
                ds = getAngleDistance(ths1c, ths(ts(kk)));
                ixc = ds <= opts.thetaTol;
                Yc(kk,:) = mean(YR1(ixc,:)) - YR2(ts(kk),:);
%                 Yc(kk,:) = mean(YR1(ixc,:));
            end
            errs(jj) = mean(sqrt(sum(Yc.^2,2)));
%             errs(jj) = norm(mu - mean(Yc));
        end
        [~, ixOffset] = min(errs);
        rotThetas(ii) = offsets(ixOffset);
        
        figure(1); hold on; plot(offsets, errs, 'Color', clrs(ii,:), 'LineWidth', 4);
    end
end

function gs = newGroup(ths, offset)
    ths = mod(ths + offset, 360);
    gs = score.thetaGroup(ths, score.thetaCenters(8));
end

function ds = getAngleDistance(Z, z)
    dst = @(d1,d2) abs(mod((d1-d2 + 180), 360) - 180);
    ds = bsxfun(dst, Z, z);
end
