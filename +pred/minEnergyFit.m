function [Z,U] = minEnergyFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'nDecoder', 'minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~opts.fitInLatent && strcmp(opts.decoderNm(1), 'f')
        warning('minEnergyFit must use spike decoder, not factors.');
        opts.decoderNm(1) = 'n';
    elseif opts.fitInLatent && strcmp(opts.decoderNm(1), 'n')
        warning('minEnergyFit must use factor decoder, not spikes.');
        opts.decoderNm(1) = 'f';
    end
    
    if ~opts.fitInLatent
        % using factor decoder but still fitting in spikes
        opts.decoderNm(1) = 'f';
    end
    if strcmpi(opts.minType, 'nullMean')
        warning('Fitting in latent for nullMean in minEnergyFit.');
        opts.fitInLatent = true;
    end
    
    % set upper and lower bounds
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    if opts.fitInLatent
        Y1 = B1.latents;
        Y2 = B2.latents;
    else
        Y1 = B1.spikes;
        Y2 = B2.spikes;
    end

    if opts.obeyBounds
        lb = 0.8*min(Y1); ub = 1.2*max(Y1);
%         lb = lb*0; ub(ub>=0) = 50;
    else
        lb = []; ub = [];
    end
    
    % set minimum, in latent or spike space
    Dc = D.simpleData.nullDecoder;
    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = Dc.spikeCountMean;
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(D.blocks(1).spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(Dc, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'nullMean')        
        NB2 = D.blocks(2).fDecoder.NulM2;
        YN1 = Y1*(NB2*NB2');
        mu = mean(YN1);
    else
        assert(false, 'Invalid minType for minEnergyFit');
    end
    sigma = D.simpleData.nullDecoder.spikeCountStd;
    maxSps = 2*max(B1.spikes(:));

    grps = sort(unique(D.blocks(2).thetaActualGrps16));
    gcs = zeros(numel(grps),1);

    [nt, nu] = size(Y2);
    U = nan(nt,nu);
    nrs = 0; nlbs = 0; nubs = 0;
    for t = 1:nt
%         grp = D.blocks(2).thetaActualGrps16(t);
%         if gcs(grps == grp) > 0
%             continue;
%         end
%         gcs(grps == grp) = gcs(grps == grp) + 1;
        
        if mod(t, 500) == 0
            disp(['minEnergyFit: ' num2str(t) ' of ' num2str(nt)]);
        end
        [U(t,:), isRelaxed] = pred.quadFireFit(B2, t, -mu, ...
            B2.(opts.decoderNm), opts.fitInLatent, lb, ub, Dc);
        nrs = nrs + isRelaxed;
        
        if ~opts.fitInLatent && opts.addSpikeNoise
            ut0 = U(t,:);
            c = 0;
            ut = normrnd(ut0, sigma);
            while (any(ut < 0) || any(ut > 2*maxSps)) && c < 10
                ut = normrnd(ut0, sigma);
                c = c + 1;
            end
            if ~(any(ut < 0) || any(ut > 2*maxSps))
                U(t,:) = ut;
            end
        end
        
        if numel(lb) > 0 && any(abs(U(t,:) - lb) < 1e-5)
            nlbs = nlbs + 1;
        end
        if numel(ub) > 0 && any(abs(U(t,:) - ub) < 1e-5)
            nubs = nubs + 1;
        end
    end
    if opts.fitInLatent        
        Z = U;
        if opts.addSpikeNoise
            % project to spikes, then infer latents
            sps = tools.latentsToSpikes(Z, Dc, true, true);
            Z = tools.convertRawSpikesToRawLatents(Dc, sps');
        end
    else
        Z = tools.convertRawSpikesToRawLatents(Dc, U');
%         Z = Z/Dc.FactorAnalysisParams.spikeRot;
    end
    
    NB2 = D.blocks(2).fDecoder.NulM2;
    RB2 = D.blocks(2).fDecoder.RowM2;
    Z = Z*(NB2*NB2') + D.blocks(2).latents*(RB2*RB2');
    
    if nrs > 0
        warning(['minEnergyFit relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoints.']);
    end
    if nlbs > 0 || nubs > 0
        warning(['minEnergyFit hit lower bounds ' num2str(nlbs) ...
            ' times and upper bounds ' num2str(nubs) ' times.']);
    end
    if opts.nanIfOutOfBounds && opts.obeyBounds
        opts.isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType, D);
        isOut = arrayfun(@(t) opts.isOutOfBounds(Z(t,:)), 1:nt);
        Z(isOut,:) = nan;
        c = sum(isOut);
        if c > 0
            warning(['minEnergyFit ignoring ' num2str(c) ...
                ' points outside of bounds.']);
        end
    end    
end
