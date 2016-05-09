function [isOutOfBoundsFcn, whereOutOfBounds] = boundsFcn(Y, kind)
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
    elseif strcmpi(kind, 'none')
        isOutOfBoundsFcn = @(z) false;
    end
end
