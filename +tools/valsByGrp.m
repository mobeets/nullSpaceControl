function [vs, grps] = valsByGrp(D, fcn, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('doNull', true, 'doRow', false, ...
        'blockInd', 2, 'grpName', 'thetaGrps');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~isfield(opts, 'mapInd')
        opts.mapInd = opts.blockInd;
    end
    
    B = D.blocks(opts.blockInd);    
    Y = B.latents;
    if ~isfield(opts, 'mapInd')
        opts.mapInd = opts.blockInd;
    end
    if opts.doNull
        NB = D.blocks(opts.mapInd).fDecoder.NulM2;
        Y = Y*NB;
    end
    if isfield(opts, 'doRow') && opts.doRow
        RB = D.blocks(opts.mapInd).fDecoder.RowM2;
        Y = Y*RB;
    end
    
    gs = B.(opts.grpName);
    grps = sort(unique(gs));
    vs = cell(numel(grps),1);
    
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        vs{jj} = fcn(Y(ix,:));
    end
    if all(cellfun(@numel, vs) == 1)
        vs = cell2mat(vs);
    end        
end
