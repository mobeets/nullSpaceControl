function [vs, bs] = getValuesByTrialByBlockByGroup(D, fldNm, grpNm, grpTrial)
    if nargin < 4
        grpTrial = true;
    end

    [vrs, brs] = behav.getValuesByTrialByBlock(D, fldNm, grpTrial);
    if ~isempty(grpNm)
        gs = D.blocks(1).(grpNm);
        gs = gs(~isnan(gs));
        grps = sort(unique(gs));
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
            if grpTrial
                ts = D.blocks(ii).trial_index;
                gs = grpstats(gs, ts);
            end
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
