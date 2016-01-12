function D = nullActivity(D, NB)

    % mean/cov of null activity for observed activity
    ix = strcmp('observed', {D.hyps.name});
    D.hyps(ix).null.B1Col = nullActivityPerCol(...
        D.blocks(1).latents, D.blocks(1), NB);
    D.hyps(ix).null.B1 = nullActivityAll(...
            D.blocks(1).latents, D.blocks(1), NB);
    
    % mean/cov of null activity in second block
    for ii = 1:numel(D.hyps)
        D.hyps(ii).null.B2Col = nullActivityPerCol(...
            D.hyps(ii).latents, D.blocks(2), NB);
        D.hyps(ii).null.B2 = nullActivityAll(...
            D.hyps(ii).latents, D.blocks(2), NB);
    end    
    
end

function scs = nullActivityPerCol(latents, B, NB)
    scs = struct([]);
    for ii = 1:size(NB,2)
        scs = [scs nullActivityAll(latents, B, NB)];
    end
end

function sc = nullActivityAll(latents, B, NB)
    sc = struct();
    [sc.zMu, sc.zCov, sc.zNull] = pred.nullActivityByTrgAng(B, ...
        latents, NB);
end
