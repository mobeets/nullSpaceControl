function Z = habKdeFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetaGrps', ...
        'doSample', true, 'obeyBounds', true, 'useRowMeanShift', true, ...
        'fullKde', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    gs = B2.(opts.thetaNm);
    grps = sort(unique(gs));
    
    YN1 = B1.latents*NB2;
    YR1 = B1.latents*RB2;
    YR2 = B2.latents*RB2;
    gs1 = B1.(opts.thetaNm);
    isOutOfBounds = pred.boundsFcn(B1.latents);    
    
    d = 0;
    h = 0.1;
    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,size(YN1,2));
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        ix1 = gs1 == grps(ii);
        
        YR2c = YR2(ix,:);
        YR1c = YR1(ix1,:);

        if opts.fullKde
            % note: need to implement rejection sampling here
            % because I can't just generate all combos of 8-d
            % see: https://www.amstat.org/sections/srms/proceedings/y2008/Files/300875.pdf
            Phatfcn = ksdensity_nd(YN1(ix1,:));
            Zsc = tools.kde_samp(YN1(ix1,:), Phatfcn, sum(ix));
            Zsamp(ix,:) = Zsc;
                
        else
            delta = mean(YR2c) - mean(YR1c);
            for jj = 1:size(YN1,2)

                Yc = YN1(ix1,jj);

                if opts.useRowMeanShift
                    mdl = fitlm(YR1c, Yc);
                    c_delta = 1*mdl.Coefficients.Estimate(2:end)'*delta';
                else
                    c_delta = 0;
                end

                Phatfcn = ksdensity_nd(Yc, 0.1);
                xs = linspace(min(Yc)-range(Yc)/3, max(Yc)+range(Yc)/3, 1000);
                ysh = Phatfcn(xs');
                if abs(trapz(xs, ysh)-1) > 1e-3
                    error('cdf incomplete.');
                end
                F = cumsum(ysh)/max(cumsum(ysh));

                us = rand([sum(ix) 1]);
                errs = (bsxfun(@plus, F, -us)).^2;
                [~,ixs] = min(errs, [], 2);
                Zsamp(ix,jj) = xs(ixs) + 1*c_delta;

            end
        end
        ts = 1:nt; ts = ts(ix);
        for t = 1:numel(ts)
            c = 0;
            if isOutOfBounds(Zsamp(ts(t),:)*NB2' + ...
                    Zr(ts(t),:)) && c < 10
                c = c + 1;
                
                d = d + 1;
                c = 10;
                
            end
            if c > 1 && c < 10
                d = d;% + 1;
            end
        end
    end
    
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ' hab-kde samples to lie within bounds']);
    end
    Zn = Zsamp*NB2';
    Z = Zr + Zn;

end
