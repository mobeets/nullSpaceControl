function [zMu, zCov, zNull, zFull] = nullActivityByTrgAng(B, zAll, NB)
        
    assert(size(NB,1) == size(zAll,1));
%     DecVel = B.extras.decodedVelocities;
%     decTargs = cellfun(@(v) rad2deg(atan(v(:,2)./v(:,1))), DecVel, 'uni', 0);
    decTargs = B.theta + 180;

    targs = B.extras.targetAngles;
    alltargs = unique(targs); % rad2deg((0:7).*(pi/4));
    ntargs = numel(alltargs);
    Ak = [alltargs - 22.5; alltargs + 22.5]';
    Ak(Ak < 0) = 360 + Ak(Ak < 0);
    
    zMu = cell(ntargs,1);
    zCov = cell(ntargs,1);
    zNull = cell(ntargs,1);
    zFull = cell(ntargs,1);

    for ii = 1:numel(alltargs)
        % for each trial in ix, keep times where DecTrg is in Akc
%         ix1 = targs == alltargs(ii);
        ix1 = true(size(targs)); % use all, regardless of goal
        ix2 = decTargsInRange(decTargs, Ak(ii,:));

        zFull{ii} = zAll(:,ix1&ix2);
        zNull{ii} = NB'*zFull{ii};
        zMu{ii} = mean(zNull{ii});
        zCov{ii} = cov(zNull{ii});
        % might actually want SE if NB is a basisVec (see reformatTheta)
    end

end

function ix = decTargsInRange(decTargs, bnds)
    if bnds(1) <= bnds(2)
        ix = decTargs >= bnds(1) & decTargs <= bnds(2);
    else % e.g. [337.5 22.5]
        ix = decTargs >= bnds(1) | decTargs <= bnds(2);
    end
end
