function [Z, inds] = minEnergySampleFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'nDecoder', 'minType', 'baseline', ...
        'fitInLatent', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B = D.blocks(2);
    if opts.fitInLatent
        Y1 = B.latents;
        Y2 = B.latents;
    else
        Y1 = B.spikes;
        Y2 = B.spikes;
    end
    RB2 = B.(opts.decoderNm).RowM2;
    NB2 = B.(opts.decoderNm).NulM2;
    Un1 = Y1*(NB2*NB2');
    Ur = Y2*(RB2*RB2');

    dec = D.simpleData.nullDecoder;
    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = zeros(1,size(Y2,2));
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = dec.spikeCountMean;        
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(D.blocks(1).spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(dec, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = zeros(1,size(Y2,2));
    end
    maxSps = max(Y1(:));
    
    nt = size(Y2,1);
    Un = nan(size(Ur));
    inds = nan(nt,1);
    nInvalids = 0;
    for t = 1:nt
        usc = bsxfun(@plus, Un1, Ur(t,:)); % current spikes considered
        usc = usc(~any(usc<0|usc>2*maxSps,2),:); % ignore oob spikes
        % find ind of us s.t. us is nearest zero spikes
        ds = sqrt(sum(bsxfun(@plus, usc, -mu).^2,2));
        [~, ind] = min(ds);
        if numel(ds) == 0
            nInvalids = nInvalids + 1;
            continue;
        end
        inds(t) = ind;
        Un(t,:) = Un1(ind,:);
    end
    if nInvalids > 0
        warning(['minEnergySampleFit: ' num2str(nInvalids) ...
            ' samples had no valid points.']);
    end

    U = Ur + Un;
    % now convert to latents
    if opts.fitInLatent
        Z = U;
    else
        Z = tools.convertRawSpikesToRawLatents(dec, U');
    end
%     NBz = D.blocks(2).fDecoder.NulM2;
%     RBz = D.blocks(2).fDecoder.RowM2;
%     Z = Z*(NBz*NBz') + D.blocks(2).latents*(RBz*RBz');
end
