function D = addDecoders(D)

    nd = D.simpleData.nullDecoder;
    sd = D.simpleData.shuffles;
    nMap1 = nd.rawSpikes;
    nMap2 = sd.rawSpikes;
    fMap1 = getFactorNullDecoder(nd);
    fMap2 = getFactorShuffleDecoder(sd, nd);
    
    assert(numel(D.blocks) == 3);
    D.blocks(1).nDecoder = nMap1;
    D.blocks(2).nDecoder = nMap2;
    D.blocks(3).nDecoder = nMap1;
    D.blocks(1).fDecoder = fMap1;
    D.blocks(2).fDecoder = fMap2;
    D.blocks(3).fDecoder = fMap1;

end

function fm = getFactorNullDecoder(nd)

    fm.M0 = nd.normalizedSpikes.M0;
    fm.M1 = nd.normalizedSpikes.M1;
    fm.M2 = [];
    
    % placeholder
    fm.M2 = nd.normalizedSpikes.M2 * nd.normalizedSpikes.beta';
    
%     [M2, M1, M0, beta, k] = simplifyKalman(kalmanInitParams, ...
%       'raw', 'factors');
%      ^ these should match

end

function fm = getFactorShuffleDecoder(sd, nd)
    
    fm.M0 = [];
    fm.M1 = [];
    fm.M2 = [];
    
    % placeholder
    fm.M0 = sd.normalizedSpikes.M0;
    fm.M1 = sd.normalizedSpikes.M1;
    fm.M2 = sd.normalizedSpikes.M2 * sd.normalizedSpikes.beta';

end
