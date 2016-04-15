function [lrn, L_bin, L_proj, L_max, L_raw, ls] = grpLearnMaxAndRaw(vs, bs)
    nflds = numel(vs);
    L_best = nan(nflds,1);
    L_max = nan(nflds,1);
    L_raw = cell(nflds,1);
    ls = cell(nflds,1);
    for ii = 1:nflds
        [L_best(ii), L_max(ii), L_raw{ii}, ls{ii}] = ...
            behav.singleLearnMaxAndRaw(vs{ii}, bs);
    end
    L_raw = cell2mat(L_raw);
    
    L_mx = L_max/norm(L_max);
    L_proj = (L_raw'*L_mx)*L_mx';
    L_bin = sqrt(sum(L_proj.^2,2))/norm(L_max);
    lrn = max(L_bin);
end
