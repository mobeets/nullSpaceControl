function df = spikeDecoderToFactorDecoder(dn, simpleDataDecoder)
% dn = spike decoder
% returns df, the factor decoder
% n.b. we just need simpleDataDecoder for the factor analysis params
% 

    L = simpleDataDecoder.FactorAnalysisParams.L;    
    ph = simpleDataDecoder.FactorAnalysisParams.ph;
    mu = simpleDataDecoder.spikeCountMean;
    sigma = simpleDataDecoder.spikeCountStd;
    B = L'/(L*L'+diag(ph));
        
    df.M2 = dn.M2/(B/diag(sigma));
    df.M1 = dn.M1;
    df.M0 = dn.M0 + df.M2*(B/diag(sigma))*mu';
    
end
