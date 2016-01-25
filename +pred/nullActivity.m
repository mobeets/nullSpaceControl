function D = nullActivity(D)

    NBf = @(ii) tools.getNullBasis(D.blocks(ii).fDecoder.M2);
    
    % mean/cov of null activity in second block
    for ii = 1:numel(D.hyps)
        D.hyps(ii).null(1) = nullActivityAll(...
            D.hyps(ii).latents, D.blocks(2), NBf(1));
        D.hyps(ii).null(2) = nullActivityAll(...
            D.hyps(ii).latents, D.blocks(2), NBf(2));
    end    
    
    % mean/cov of null activity for observed activity
    ix = strcmp('observed', {D.hyps.name});
    D.hyps(ix).nullOG(1) = nullActivityAll(...
        D.blocks(1).latents, D.blocks(1), NBf(1));
    D.hyps(ix).nullOG(2) = nullActivityAll(...
        D.blocks(1).latents, D.blocks(1), NBf(2));

end

function sc = nullActivityAll(latents, B, NB)
    sc = struct();
    if isempty(latents)
        sc.zMu = []; sc.zCov = []; sc.zNull = []; sc.zNullBin = [];
        return;
    end
    sc.zNull = latents*NB;
    [sc.zMu, sc.zCov, ~, sc.zNullBin] = pred.avgByThetaGroup(B, sc.zNull);
end
