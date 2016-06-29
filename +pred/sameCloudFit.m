function Z = sameCloudFit(D, opts)
% currently, parameters are thetaTol and minDist
% 	* thetaTol can be removed by setting thetaNm := thetaGrps
%   for some days this is actually an improvement; on most, it's about
%   the same
%   * for minDist, this is basically equivalent to a kNN of 20
%
% and last i checked, pruning that takes the closest point is basically
%   identical to normal pruning for all sessions, 
%       except it's higher in covariance error on 20120709
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaTol', 30, ...
        'thetaNm', 'thetas', 'rotThetas', 0, 'minDist', 0.20, ...
        'grpNm', 'thetaGrps', 'kNN', nan, 'doSample', true, ...
        'obeyBounds', true, 'boundsType', 'marginal', 'minNorm', false, ...
        'boundsThresh', inf);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
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
    N1 = Z1*NB2;
    R1 = Z1*RB2;    
    R2 = Z2*RB2;
    [nt, nn] = size(Z2);
    
    Z1nrms = sqrt(sum(Z1.^2,2));
    
    opts.isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType);
    resampleCount = 0;
    invalidCount = 0;
    
    ths1 = B1.(opts.thetaNm);
    ths = B2.(opts.thetaNm);
    grps = B2.(opts.grpNm);
    ngs = numel(unique(grps));
    
    if numel(opts.rotThetas) == 1
        opts.rotThetas = opts.rotThetas*ones(ngs,1);
    end
    assert(numel(opts.rotThetas) == ngs);
    didWarn = false;
    
    Zsamp = nan(nt,nn);
    for t = 1:nt
        % calculate distance in current row space
        %   of all intuitive activity from current activity
        ds0 = getDistances(R1, R2(t,:));
        ds = ds0;
        opts.isOutOfBndsNul = pred.boundsFcnCond(R2(t,:), R1, N1, ...
            opts.boundsThresh);
        
        if ~isnan(opts.thetaTol) % make distance inf if theta is too different
            ind = grps(t) == score.thetaCenters(ngs);
            rotTheta = opts.rotThetas(ind);
            th = mod(ths(t) + rotTheta, 360);
            dsThetas = getAngleDistance(ths1, th);
            if sum(dsThetas <= opts.thetaTol) == 0
                assert(sum(dsThetas <= 2*opts.thetaTol) > 0);
                ds(dsThetas > 2*opts.thetaTol) = inf;
                if ~didWarn
                    disp('Increasing theta_tol');
                    didWarn = true;
                end
            else
                ds(dsThetas > opts.thetaTol) = inf;
            end            
        end
        if isnan(opts.minDist)
            if ~isnan(opts.kNN)
                [~,ix] = sort(ds);
                kNNinds = ix(1:min(opts.kNN, sum(~isinf(ds)))); % take nearest neighbors
                if opts.minNorm % pick neighbor with smallest norm
                    [~,ix] = min(Z1nrms(kNNinds));
                    kNNinds = kNNinds(ix);
                end
                [Zsamp(t,:),d] = meanOrSample(Z1(kNNinds,:), Zr(t,:), NB2, opts);
            else
                [Zsamp(t,:),d] = meanOrSample(Z1(~isinf(ds),:), Zr(t,:), NB2, opts);
            end
            resampleCount = resampleCount + d;
            continue;
        end
        
        ix = ds <= opts.minDist;
        
        if sum(ix) == 0 % pick the nearest point
            [~,ind] = min(ds);
            ix(ind) = true;
            invalidCount = invalidCount + 1;
        end
        [Zsamp(t,:),d] = meanOrSample(Z1(ix, :), Zr(t,:), NB2, opts);
        resampleCount = resampleCount + d;
    end
    if invalidCount > 0
        warning([num2str(invalidCount) ' of ' num2str(nt) ...
            ' cloud samples took the nearest point.']);
    end
    if resampleCount > 0
        warning(['Corrected ' num2str(resampleCount) ...
            ' cloud samples to lie within bounds.']);
    end
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

end

function [z,d] = meanOrSample(zs, zr, NB2, opts)
    d = 0;
    c = 0;
    outOfBnds = @(z) opts.isOutOfBounds(z*(NB2*NB2') + zr) || ...
        opts.isOutOfBndsNul(z*NB2);
%     outOfBnds = @(z) opts.isOutOfBounds(z*(NB2*NB2') + zr);
    if opts.doSample
        z = zs(randi(size(zs,1),1),:);
        while opts.obeyBounds && outOfBnds(z) && c < 10
            z = zs(randi(size(zs,1),1),:);
            c = c + 1;
        end
        if c > 1 && c < 10
            d = 1;
        end
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
