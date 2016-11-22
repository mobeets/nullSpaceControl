function [sc, gs] = nullActivityAll(latents, B, NB, opts)
    idxFld = opts.idxFldNm;
    gs = B.(opts.scoreGrpNm);    
    
    if ~isempty(idxFld) && isfield(B, idxFld) && ~isempty(B.(idxFld))
        ix = B.(idxFld);
        if numel(ix) ~= numel(gs)
            [numel(ix) numel(gs)]
            error([idxFld ' is not the same size as thetas']);
        end
        gs = gs(ix);
        latents = latents(ix,:);
    end
    sc = struct();
    if isempty(latents)
        sc.zNull = []; sc.zMu = {}; sc.zCov = {}; sc.zNullBin = {};
        return;
    end
    sc.zNull = latents*NB;
    
    if ~any(isnan(opts.nullCols)) && ~isempty(opts.nullCols)
        sc.zNull = sc.zNull(:, opts.nullCols);
    end
    
%     warning('setting latents with bad spikes to nan');
%     [isOutOfBoundsFcn, ~] = pred.boundsFcn(nan, 'spikes', D);
%     ixBad = isOutOfBoundsFcn(latents);
%     latents = latents(~ixBad,:);
% %     gs = gs(~ixBad);
    
    [sc.zMu, sc.zCov, sc.zNullBin, sc.grps] = pred.avgByThetaGroup(sc.zNull, gs);
end
