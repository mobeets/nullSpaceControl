function D = quickLoadByDate(dtstr, params, opts)
% opts
%   - doRotate: rotate latents to be orthonormal
%   - doStretch: stretch latents once orthonormalized
%   - doSwap: % exchange intuitive and perturbation blocks
% 

    if nargin < 2
        params = struct();
    end
    if nargin < 3
        opts = struct();        
    end
    defopts = struct('doRotate', true, 'doStretch', true, 'doSwap', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if isa(dtstr, 'double')
        dts = io.getDates();
        dtstr = dts{dtstr};
    end
    
    D = io.loadDataByDate(dtstr);
    D.params = io.updateParams(D.params, params, true);
    D.opts = opts;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = io.addImeDecoders(D);
    
    if opts.doRotate
        D = tools.rotateLatentsUpdateDecoders(D, opts.doStretch);
    end
    if opts.doSwap
        B1 = D.blocks(1);        
        B2 = D.blocks(2);
        D.blocks(1) = B2;
        D.blocks(2) = B1;
    end
end

