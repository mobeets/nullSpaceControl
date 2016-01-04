function [zMu, zCov, zNull, zFull] = nullActivityByTrgAng(d, Z, NB)
    
    Trg = d.targetAngles;
    DecVel = d.decodedVelocities;
    DecTrg = cellfun(@(v) rad2deg(atan(v(:,2)./v(:,1))), DecVel, 'uni', 0);

    targs = unique(Trg); % rad2deg((0:7).*(pi/4));
    Ak = [targs - 22.5; targs + 22.5]';
    nt = numel(targs);
    ndb = size(NB,2);
    
    zMu = cell(nt,1);
    zCov = cell(nt,1);
    zNull = cell(nt,1);
    zFull = cell(nt,1);

    for ii = 1:numel(targs)
        ix = Trg == targs(ii);
        
        % for each trial in ix, keep times where DecTrg is in Akc
        Akc = Ak(ii,:);
        zFull{ii} = [];
        
        zNull{ii} = NB'*zFull{ii};
        zMu{ii} = mean(zNull{ii});
        zCov{ii} = cov(zNull{ii});
    end

end
