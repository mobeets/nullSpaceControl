function D = nullActivity(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'idxFldNm', '', ...
        'scoreGrpNm', 'thetaGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~strcmp(opts.decoderNm, 'fDecoder')
        warning(['Predicting null activity using "' opts.decoderNm '"']);
    end

    NBf = @(ii) D.blocks(ii).(opts.decoderNm).NulM2;
    
    % mean/cov of null activity in second block
    for ii = 1:numel(D.hyps)
        D.hyps(ii).null(1) = nullActivityAll(...
            D.hyps(ii).latents, D.blocks(2), NBf(1), opts);
        D.hyps(ii).null(2) = nullActivityAll(...
            D.hyps(ii).latents, D.blocks(2), NBf(2), opts);
    end    
    
    % mean/cov of null activity for observed activity
    ix = strcmp('observed', {D.hyps.name});
    D.hyps(ix).nullOG(1) = nullActivityAll(...
        D.blocks(1).latents, D.blocks(1), NBf(1), opts);
    D.hyps(ix).nullOG(2) = nullActivityAll(...
        D.blocks(1).latents, D.blocks(1), NBf(2), opts);

end

function sc = nullActivityAll(latents, B, NB, opts)
    idxFld = opts.idxFldNm;
    grpFld = opts.scoreGrpNm;
    
    gs = B.(grpFld);
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
    [sc.zMu, sc.zCov, sc.zNullBin] = pred.avgByThetaGroup(sc.zNull, gs);
end
