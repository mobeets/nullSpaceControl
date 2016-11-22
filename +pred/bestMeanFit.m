function Z = bestMeanFit(D, opts)
% choose intuitive pt closest to nul val
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'nullCols', [], ...
        'grpNm', 'thetaActualGrps', 'idxFldNm', '', ...
        'boundsType', 'marginal', 'obeyBounds', false, ...
        'addNoise', false, 'fitInLatent', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if strcmp(opts.decoderNm(1), 'f') && ~opts.fitInLatent
        opts.decoderNm(1) = 'n';
        warning('changing to spike decoder.');
    elseif strcmp(opts.decoderNm(1), 'n') && opts.fitInLatent
        opts.decoderNm(1) = 'f';
        warning('changing to factor decoder.');
    end
    
    B = D.blocks(2);
    NB2 = B.(opts.decoderNm).NulM2;
    RB2 = B.(opts.decoderNm).RowM2;
    nt = size(B.time,1);    
    
    B1 = D.blocks(1);
    NB1 = B1.(opts.decoderNm).NulM2;
    gs1 = B1.(opts.grpNm);
    
    if opts.fitInLatent
        Z1 = B1.latents;
        Z2 = B.latents;        
    else
        Z1 = B1.spikes;
        Z2 = B.spikes;
    end
    
    % find best null space mean
    mu = bestMeanObj(Z1, NB1, gs1);
    Zn = repmat(mu, nt, 1)*(NB2*NB2');
    Zr = Z2*(RB2*RB2');
    Z = Zn + Zr;
    
    % add noise (or not)
    if opts.addNoise && ~opts.fitInLatent
        sigma = D.simpleData.nullDecoder.spikeCountStd;
        nse = normrnd(zeros(nt, numel(sigma)), repmat(sigma, nt, 1));
        Z = Z + nse;
    elseif opts.addNoise
        sigma = D.simpleData.nullDecoder.FactorAnalysisParams.factorStd;
        nse = normrnd(zeros(nt, numel(sigma)), repmat(sigma, nt, 1));
        Z = Z + nse;
    end

%     % if noise added, need to resample invalid points
%     if opts.obeyBounds && opts.addNoise        
%         isOutOfBounds = pred.boundsFcn(Z1, opts.boundsType, D);
%         ixOob = isOutOfBounds(Z);
%         n0 = sum(ixOob);
%         maxC = 10;
%         c = 0;        
%         while sum(ixOob) > 0 && c < maxC
%             Zsamp = Z1(randi(size(Z1,1),sum(ixOob),1),:);
%             Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
%             ixOob = isOutOfBounds(Z);
%             c = c + 1;
%         end
%         if n0 - sum(ixOob) > 0
%             warning(['Corrected ' num2str(n0 - sum(ixOob)) ...
%                 ' unconstrained samples to lie within bounds']);
%         end
%     end
    
    if ~opts.fitInLatent
        dec = D.simpleData.nullDecoder;
        Z = tools.convertRawSpikesToRawLatents(dec, Z');
    end

end

function sol = bestMeanObj(Z, NB, gs)
    % search for best mean rate to predict
    
    zMu0 = pred.avgByThetaGroup(Z*NB, gs);
    nt = size(Z,1);
    obj = @(mu) score.errOfMeans(zMu0, ...
        pred.avgByThetaGroup(repmat(mu, nt, 1)*NB, gs));
    mu0 = mean(Z);
    sol = fminunc(obj, mu0);
    
end
