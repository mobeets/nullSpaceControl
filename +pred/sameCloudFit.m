function Z = sameCloudFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaTol', 30, ...
        'rotThetas', 0, 'minDist', 0.35, 'kNN', nan, 'doSample', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if numel(opts.rotThetas) == 1
        opts.rotThetas = opts.rotThetas*ones(8,1);
    end
    assert(numel(opts.rotThetas) == 8);
    if ~isnan(opts.kNN) && ~isnan(opts.minDist)
        warning('Ignoring kNN option because minDist is set.');
    end
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    Z1 = B1.latents;
    Z2 = B2.latents;
    Zr = Z2*(RB2*RB2');
    R1 = Z1*RB2;
    R2 = Z2*RB2;
    [nt, nn] = size(Z2);

    invalidCount = 0;
    Zsamp = nan(nt,nn);
    for t = 1:nt        
        % calculate distance in current row space
        %   of all intuitive activity from current activity
        ds = getDistances(R1, R2(t,:));
        
        if ~isnan(opts.thetaTol) % make distance inf if theta is too different
            ind = B2.thetaGrps(t) == score.thetaCenters(8);
            rotTheta = opts.rotThetas(ind);
            th = mod(B2.thetas(t)+rotTheta, 360);
            dsThetas = getAngleDistance(B1.thetas, th);
            ds(dsThetas > opts.thetaTol) = inf;
        end
        if isnan(opts.minDist)
            if ~isnan(opts.kNN)
                [~,ix] = sort(ds);
                kNNinds = ix(1:opts.kNN); % take nearest neighbors
                Zsamp(t,:) = meanOrSample(Z1(kNNinds,:), opts);
            else
                Zsamp(t,:) = meanOrSample(Z1(~isinf(ds),:), opts);
            end
            continue;
        end
        
        ix = ds <= opts.minDist;
        
        if sum(ix) == 0 % pick the nearest point
            [~,ind] = min(ds);
            ix(ind) = true;
            invalidCount = invalidCount + 1;
        end
%         % add to minimum distance until there is at least one point in range
%         c = 2;
%         while sum(ix) == 0
%             ix = ds <= c*opts.minDist;
%             c = c + 1;
%         end
%         if c > 2
%             invalidCount = invalidCount + 1;
%         end
        
        Zsamp(t,:) = meanOrSample(Z1(ix, :), opts);
    end
    if invalidCount > 0
        warning([num2str(invalidCount) ' of ' num2str(nt) ...
            ' cloud samples took the nearest point.']);
    end
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

end

function z = meanOrSample(zs, opts)
    if opts.doSample
        ind = randi(size(zs,1),1);
        z = zs(ind,:);
    else
        z = nanmean(zs);
    end
end

function ds = getDistances(Z, z)
    ds = bsxfun(@minus, Z, z);
    ds = sqrt(sum(ds.^2,2));
end

function ds = getAngleDistance(Z, z)
    dst = @(d1,d2) abs(mod((d1-d2 + 180), 360) - 180);
    ds = bsxfun(dst, Z, z);
end
