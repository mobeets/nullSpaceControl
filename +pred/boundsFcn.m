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
        maxSps = 50;
        
        dec = D.simpleData.nullDecoder;
        ph = dec.FactorAnalysisParams.ph;
        
        mult = 0.01;
        whereOutOfBounds = @(U) cell2mat(arrayfun(@(ii) ...
            ~isInRange(U(ii,:), ph, minSps, maxSps, mult), ...
            1:size(U,1), 'uni', 0)');
        isOutOfBoundsFcn = @(z) any(whereOutOfBounds(...
            tools.latentsToSpikes(z, dec, false, true)), 2);
        
%         whereOutOfBounds = @(u) u < minSps | u > maxSps;
%         isOutOfBoundsFcn = @(z) any(whereOutOfBounds(...
%             tools.latentsToSpikes(z, dec, false, true)),2);

    elseif strcmpi(kind, 'none')
        isOutOfBoundsFcn = @(z) false;
    end
end

function isGood = isInRange(u, ph, minSps, maxSps, mult)
   
    isGood = ((u > minSps) | (u + mult*ph' > minSps)) & ...
        ((u < maxSps) | (u - mult*ph' < maxSps));
    
    isDefGood = (u > minSps) & (u < maxSps);
    isBarelyGood = isGood & ~isDefGood;
    if sum(isBarelyGood) > 1
        [sum(~isGood) sum(isDefGood) sum(isBarelyGood)]
    end

%     umn = u(u < minSps);
%     phmn = ph(u < minSps);
%     umx = u(u > minSps);
%     phmx = ph(u > minSps);    
%     isGood = all(umn + mult*phmn > minSps) & all(umx - mult*phmx < maxSps);
end
