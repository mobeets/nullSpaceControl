function Z = uniformSampleFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'sampleInLatent', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B = D.blocks(2);
    if ~opts.sampleInLatent && isempty(strfind(opts.decoderNm, 'n'))
        warning('uniform sample: using spike decoder');
        opts.decoderNm = strrep(opts.decoderNm, 'f', 'n');
    end
    RB = B.(opts.decoderNm).RowM2;
    NB = B.(opts.decoderNm).NulM2;
    if opts.sampleInLatent
        Y = B.latents;
        Z1 = D.blocks(1).latents;
    else
        Y = B.spikes;
        Z1 = D.blocks(1).spikes;
    end
    Zr = Y*(RB*RB');
    
    nt = size(Y,1);
    Zn = getSamples(Z1*NB, nt);
    Z = Zr + Zn*NB';
    
    if opts.obeyBounds
        % resample invalid points
        isOutOfBounds = pred.boundsFcn(Z1, opts.boundsType, D);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        maxC = 10;
        c = 0;        
        while sum(ixOob) > 0 && c < maxC
            Zn = getSamples(Z1*NB, sum(ixOob));
            Z(ixOob,:) = Zr(ixOob,:) + Zn*NB';
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            warning(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' uniform sample samples to lie within bounds']);
        end
    end
    
    if ~opts.sampleInLatent
        dec = D.simpleData.nullDecoder;
        Z = tools.convertRawSpikesToRawLatents(dec, Z');
    end
    
end

function Zsamp = getSamples(Z, n)
%
% generate n random samples of dim size(Z,2)
%   with the samples obeying the empirical
%   upper/lower bounds observed in Z
%
    mn = min(Z);
    mx = max(Z);
    Zsamp = rand(n, size(Z,2));
    Zsamp = bsxfun(@plus, mn, bsxfun(@times, (mx-mn), Zsamp));
    
end
