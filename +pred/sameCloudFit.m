function Z = sameCloudFit(D, d_min, theta_tol)
    if nargin < 2
        d_min = nan;
    end
    if nargin < 3
        theta_tol = nan;
    end
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.fDecoder.NulM2;
    RB2 = B2.fDecoder.RowM2;
    [nt, nn] = size(B2.latents);
    
    Z1 = B1.latents;
    Z2 = B2.latents;
    R1 = Z1*RB2;
    R2 = Z2*RB2;

    Zn = nan(nt,nn);
    for t = 1:nt        
        % calculate distance in current row space
        %   of all intuitive activity from current activity
        ds = getDistances(R1, R2(t,:));
        
        if ~isnan(theta_tol) % make distance inf if theta is too different
            theta = B2.thetas(t) + 180;
            bnds = mod([theta - theta_tol theta + theta_tol], 360);
            nearbyIdxs = tools.isInRange(B1.thetas + 180, bnds);
            ds(~nearbyIdxs) = inf;
            
%             dsThetas = getAngleDistance(B1.thetas+180, B2.thetas(t)+180);
%             ds(dsThetas > theta_tol) = inf;
        end
        
        % somehow weight ds and dsThetas? they should both be similar maybe

        if isnan(d_min) || sum(ds <= d_min) == 0 % take nearest activity
            [~,ind] = min(ds);
            zf = Z1(ind,:);
        else % sample from nearby activity
            zfa = Z1(ds <= d_min, :);
            ind = randi(size(zfa,1),1);
            zf = zfa(ind,:);
        end
        Zn(t,:) = zf;
    end
    Z = Z2*(RB2*RB2') + Zn*(NB2*NB2');

end

function ds = getDistances(Z, z)
    ds = bsxfun(@minus, Z, z);
    ds = sqrt(sum(ds.^2,2));
end

function ds = getAngleDistance(Z, z)
    dst = @(d1,d2) min(abs(d1-360 - d2), abs(d1-d2));
    ds = bsxfun(dst, Z, z);
end
