function [ths, grps, D] = asymptotesByDt(dtstr, nms, grpNm, opts, bind)
    if nargin < 3
        grpNm = '';
    end
    if nargin < 4
        opts = struct();
    end
    if nargin < 5
        bind = 2;
    end
    % load
    params = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
    D = io.quickLoadByDate(dtstr, params);
    B = D.blocks(bind);
    
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
        showAsymps(xs, ys, ths{jj}, nms{jj}, dtstr, opts);
    end
    ths = cell2mat(ths');
    grps = sort(unique(gs));

end

function showAsymps(xsb, ysb, th, nm, dtstr, opts)
    [xsb, ysb, ~] = behav.smoothAndBinVals(xsb, ysb, opts);
    plot.init;
    plot(xsb, ysb, '.');
    plot([th th], ylim, 'k--');
    ylabel(nm);
    xlabel('trial_index');
    title(dtstr);
    saveas(gcf, 'plots/tmp.png');
end
