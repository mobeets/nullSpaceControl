function [lrn, L_bin, L_proj, L_best, L_max, L_raw, ls] = ...
    learningAllTrials(D, flds, grpNm, binSz, grpTrial)
% warning: trial_length will include incorrect trials
% 
    if nargin < 2 || isempty(flds)
        flds = {'isCorrect', 'trial_length'};
    end
    if nargin < 3
        grpNm = ''; % i.e., no groups (all trials in same group)
    end
    if nargin < 4
        binSz = 50;
    end
    if nargin < 5
        grpTrial = true;
    end
    flipSign = ismember(flds, {'trial_length', 'angErrorAbs', 'angError'});
    
    vs = cell(numel(flds),1);
    bs = cell(numel(flds),1);
    for ii = 1:numel(flds)
        [vs{ii}, bs{ii}] = behav.getValuesByTrialByBlockByGroup(D, ...
            flds{ii}, grpNm, grpTrial);
    end
    
    ngrps = numel(vs{1});
    lrn = cell(ngrps,1);
    L_bin = cell(ngrps,1);
    L_proj = cell(ngrps,1);
    L_best = cell(ngrps,1);
    L_max = cell(ngrps,1);
    L_raw = cell(ngrps,1);
    ls = cell(ngrps,1);
    for jj = 1:ngrps
        vc = cell(numel(flds),1);
        for ii = 1:numel(flds)
            vc{ii} = vs{ii}{jj};
            bc = bs{ii}{jj};
        end
        [lrn{jj}, L_bin{jj}, L_proj{jj}, L_best{jj}, L_max{jj}, ...
            L_raw{jj}, ls{jj}] = behav.grpLearnMaxAndRaw(vc, bc, ...
            flipSign, binSz);
    end
    
    if ngrps == 1
        lrn = lrn{1};
        L_bin = L_bin{1};
        L_proj = L_proj{1};
        L_best = L_best{1};
        L_max = L_max{1};
        L_raw = L_raw{1};
        ls = ls{1};
    else
        lrn = cell2mat(lrn);
%         L_bin = cell2mat(L_bin')';
%         L_best = cell2mat(L_best')';
%         L_max = cell2mat(L_max')';
    end

end
