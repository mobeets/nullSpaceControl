function D = addMissingData(D)
    if ~isfield(D.simpleData, 'targetAngles')
        D.simpleData.targetAngles = addAngles(D.simpleData.targetLocations);
    end
    if ~isfield(D.simpleData, 'nullDecoder')
        D.simpleData.nullDecoder = addNullDecoder(D);
    end
    if ~isfield(D.simpleData.shuffles, 'rawSpikes')
        D.simpleData.shuffles.rawSpikes = addRawSpikesShuffleDecoder(D);
    end    
end

function dec = addNullDecoder(D)
    
    dec.FactorAnalysisParams = D.kalmanInitParams.FactorAnalysisParams;
    dec.FactorAnalysisParams.ph = dec.FactorAnalysisParams.Ph;
    dec.FactorAnalysisParams = rmfield(dec.FactorAnalysisParams, 'Ph');
    dec.FactorAnalysisParams.factorStd = dec.FactorAnalysisParams.factorSTD;
    dec.FactorAnalysisParams = rmfield(dec.FactorAnalysisParams, 'factorSTD');
    
    dec.spikeCountStd = D.kalmanInitParams.NormalizeSpikes.std;
    dec.spikeCountMean = D.kalmanInitParams.NormalizeSpikes.mean;
    
    dec.rawSpikes.M0 = D.kalmanInitParams.M0;
    dec.rawSpikes.M1 = D.kalmanInitParams.M1;
    dec.rawSpikes.M2 = D.kalmanInitParams.M2;
end

function dec = addRawSpikesShuffleDecoder(D)
    % still need to add rawSpikes to D.simpleData.shuffles
    % D.simpleData.shuffles.rawSpikes.M1 is the same as for nullDecoder's
    % but M0 and M2 are different
    if isfield(D, 'kalmanInitParamsPert')
        dec.M0 = D.kalmanInitParamsPert.M0;
        dec.M1 = D.kalmanInitParamsPert.M1;
        dec.M2 = D.kalmanInitParamsPert.M2;
    else
        dec.M1 = D.simpleData.nullDecoder.rawSpikes.M1;
        dec.M0 = [];
        dec.M2 = [];
        error('Missing kalmanInitParams for perturbation.');
    end
end

function angs = addAngles(locs)
    locs = locs(:,1:2);
    xm = median(unique(locs(:,1)));
    ym = median(unique(locs(:,2)));
    locs(:,1) = locs(:,1) - xm;
    locs(:,2) = locs(:,2) - ym;
    angs = tools.computeAngles(locs);
end
