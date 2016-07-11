function [ths, grps] = asymptotesByDt(dtstr, nms, grpNm, opts)
    if nargin < 3
        grpNm = '';
    end
    if nargin < 4
        opts = struct();
    end
    % load
    params = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
    D = io.quickLoadByDate(dtstr, params);
    B = D.blocks(2);
    
    xs = B.trial_index;
    if ~isempty(grpNm)
        gs = B.(grpNm);
    else
        gs = ones(size(xs));
    end
    ths = cell(numel(nms),1);
    for jj = 1:numel(nms)
        ys = B.(nms{jj});
        ths{jj} = behav.asymptoteByGrp(xs, ys, gs, opts);
    end
    ths = cell2mat(ths');
    grps = sort(unique(gs));

end
