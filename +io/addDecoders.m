function D = addDecoders(D)

    nMap1 = D.simpleData.nullDecoder.rawSpikes;
    nMap2 = D.simpleData.shuffles.rawSpikes;
    fMap1 = getFactorNullDecoder(D.simpleData.nullDecoder);
    fMap2 = getFactorShuffleDecoder(D.simpleData.shuffles, ...
        D.simpleData.nullDecoder);
    
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
