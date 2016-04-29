function Z = sameCloudFit(D, opts)
% currently, parameters are thetaTol and minDist
% 	* thetaTol can be removed by setting thetaNm := thetaGrps
%   for some days this is actually an improvement; on most, it's about
%   the same
%   * for minDist, this is basically equivalent to a kNN of 20
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'thetaTol', 30, ...
        'thetaNm', 'thetas', 'rotThetas', 0, 'minDist', 0.20, ...
        'kNN', 20, 'doSample', true, 'obeyBounds', true, ...
        'boundsType', 'marginal');
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
    
    opts.isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType);
    resampleCount = 0;
    invalidCount = 0;
    
    ths1 = B1.(opts.thetaNm);
    ths = B2.(opts.thetaNm);
    
    Zsamp = nan(nt,nn);
    ms = nan(nt,4);
    for t = 1:nt        
        % calculate distance in current row space
        %   of all intuitive activity from current activity
        ds0 = getDistances(R1, R2(t,:));
        ds = ds0;
        
        if ~isnan(opts.thetaTol) % make distance inf if theta is too different
            ind = B2.thetaGrps(t) == score.thetaCenters(8);
            rotTheta = opts.rotThetas(ind);
            th = mod(ths(t) + rotTheta, 360);
            dsThetas = getAngleDistance(ths1, th);
            ds(dsThetas > opts.thetaTol) = inf;
        end
        if isnan(opts.minDist)
            if ~isnan(opts.kNN)
                [~,ix] = sort(ds);
                kNNinds = ix(1:opts.kNN); % take nearest neighbors
                [Zsamp(t,:),d] = meanOrSample(Z1(kNNinds,:), opts);
            else
                [Zsamp(t,:),d] = meanOrSample(Z1(~isinf(ds),:), opts);
            end
            resampleCount = resampleCount + d;
            continue;
        end
        
        ix = ds <= opts.minDist;
        
        % [theta prune# cloud# hab#]
        ms(t,:) = [B2.thetaGrps(t) sum(ix) sum(ds0 <= opts.minDist) sum(dsThetas <= opts.thetaTol)];
        
        if sum(ix) == 0 % pick the nearest point
            [~,ind] = min(ds);
            ix(ind) = true;
            invalidCount = invalidCount + 1;
        end
        [Zsamp(t,:),d] = meanOrSample(Z1(ix, :), opts);
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

%     [mus, ~,~, gs0] = grpstats(ms(:,2:end), ms(:,1));
%     gs = sort(unique(ms(:,1)));
%     lw = 3; msz = 7;
%     figure; set(gcf, 'color', 'w');
%     hold on; set(gca, 'FontSize', 18);
%     plot(gs, mus(:,1), '-o', 'LineWidth', lw, 'MarkerSize', msz)
%     plot(gs, mus(:,2), '-o', 'LineWidth', lw, 'MarkerSize', msz)
%     plot(gs, mus(:,3), '-o', 'LineWidth', lw, 'MarkerSize', msz)
%     set(gca, 'XTick', gs);
%     set(gca, 'XTickLabel', gs0);
%     legend({'prune #', 'cloud #', 'hab #'});
%     legend boxoff;
%     xlabel('\theta');
%     ylabel('avg # pts sampled');
%     title(D.datestr);
%     mus

end

function [z,d] = meanOrSample(zs, opts)
    d = 0;
    c = 0;
    outOfBnds = opts.isOutOfBounds;
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
