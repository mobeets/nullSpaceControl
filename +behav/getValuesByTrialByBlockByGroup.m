function [vs, bs] = getValuesByTrialByBlockByGroup(D, fldNm, grpNm)
% n.b. can only be one value per group (so no thetaGrps!)

    [vrs, brs] = behav.getValuesByTrialByBlock(D, fldNm);
    if ~isempty(grpNm)
        grps = sort(unique(D.blocks(1).(grpNm)));
    else
        grps = 1;
    end
    vs = cell(numel(grps),1);
    bs = cell(numel(grps),1);
    for jj = 1:numel(vs)
        vs{jj} = [];
        bs{jj} = [];
    end    
    for ii = 1:numel(D.blocks)
        bix = brs == ii;
        vc = vrs(bix);
        bc = brs(bix);
        if ~isempty(grpNm)
            gs = D.blocks(ii).(grpNm);
            ts = D.blocks(ii).trial_index;
            gs = grpstats(gs, ts);
        else
            gs = ones(size(vc));
        end
        for jj = 1:numel(grps)            
            ix = gs == grps(jj);
            vs{jj} = [vs{jj}; vc(ix)];
            bs{jj} = [bs{jj}; bc(ix)];
        end
    end
end
