function ths = asymptoteByGrp(xs, ys, gs, opts)
% smoothes given behavior and then calculates asymptote by fitting sat-exp
% 
% xs = B.trial_index;    
% ys = double(B.(behNm));
% gs = B.(grpNm);
% 
    
    if nargin < 3
        gs = ones(size(xs));
    end
    if nargin < 4
        opts = struct();
    end
    grps = sort(unique(gs));
    ths = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        [xsb, ysb, ~] = behav.smoothAndBinVals(xs(ix), ys(ix), opts);
        if isempty(xsb)
            continue;
        end
        [~, ths(ii,:)] = tools.satExpFit(xsb, ysb);
    end
    ths(ths >= max(xs)) = nan;

end
