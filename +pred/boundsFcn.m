function [isOutOfBoundsFcn, whereOutOfBounds] = boundsFcn(Y, kind, D)
    if nargin < 2
        kind = 'marginal';
    end
    
    mns = min(Y);
    mxs = max(Y);
    
    if strcmpi(kind, 'marginal')
        whereOutOfBounds = @(z) isnan(z) | z < mns | z > mxs;
        isOutOfBoundsFcn = @(z) any(whereOutOfBounds(z));        
    elseif strcmpi(kind, 'kde')
        Phatfcn = ksdensity_nd(Y, 1);
        ps = Phatfcn(Y);
        thresh = prctile(ps, 0.05);
        isOutOfBoundsFcn = @(z) Phatfcn(z) < thresh;
        whereOutOfBounds = nan;
    elseif strcmpi(kind, 'hull')
        thresh = 0.001;
        isOutOfBoundsFcn = @(z) mean(arrayfun(@(ii) ...
            all(z < Y(ii,:)) | all(z > Y(ii,:)), 1:size(Y,1))) > thresh;
    elseif strcmpi(kind, 'spikes')
        minSps = 0;
        maxSps = 2*max(mxs);
        dec = D.simpleData.nullDecoder;
        
        if numel(mxs) == numel(dec.spikeCountMean)
            % in spike space already
            whereOutOfBounds = @(u) u < minSps | u > maxSps;
            isOutOfBoundsFcn = @(u) any(whereOutOfBounds(u),2);
            return;
        end
        
%         mult = 0;
%         ph = dec.FactorAnalysisParams.ph;
%         isInRange = @(u, ph, minSps, maxSps, mult) ...
%             ((u >= minSps) | (u + mult*ph' >= minSps)) & ...
%             ((u <= maxSps) | (u - mult*ph' <= maxSps));
%         whereOutOfBounds = @(U) cell2mat(arrayfun(@(ii) ...
%             ~isInRange(U(ii,:), ph, minSps, maxSps, mult), ...
%             1:size(U,1), 'uni', 0)');
%         isOutOfBoundsFcn = @(z) any(whereOutOfBounds(...
%             tools.latentsToSpikes(z, dec, false, true)), 2);
        
        whereOutOfBounds = @(u) u < minSps | u > maxSps;
        isOutOfBoundsFcn = @(z) any(whereOutOfBounds(...
            tools.latentsToSpikes(z, dec, false, true)),2);

    elseif strcmpi(kind, 'none')
        isOutOfBoundsFcn = @(z) false;
    end
end
