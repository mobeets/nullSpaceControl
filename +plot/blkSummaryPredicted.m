function blkSummaryPredicted(D, H, doRotate, doSolo, doTrans, NB, clrs)
    if nargin < 3
        doRotate = false;
    end
    if nargin < 4
        doSolo = false;
    end
    if nargin < 5
        doTrans = false;
    end
    if nargin < 6
        NB = [];        
    end
    if nargin < 7
        clr1 = [0.2 0.2 0.8];
        clr2 = [0.8 0.2 0.2];
        clrs = [clr1; clr2];
    end

    % project onto axes of maximum variance in observed data
    if isempty(NB)
        NB = D.blocks(2).fDecoder.NulM2;
        if doRotate
            warning('rotated...');
            [~,~,v] = svd(D.blocks(2).latents*NB);
            NB = NB*v;
        end
    end
    H0 = D.hyps(1);
    
    if doSolo
        plot.blkSummary(D.blocks(2), [], H, true, true, clrs(2,:), NB, ...
            [], doTrans);
        plot.subtitle([H.name ' in null(B2)'], 'FontSize', 14);
    else
        plot.blkSummary(D.blocks(2), [], H0, false, true, clrs(1,:), NB, ...
            [], doTrans);
        plot.blkSummary(D.blocks(2), [], H, false, true, clrs(2,:), NB, ...
            [], doTrans);        
        plot.subtitle(['observed [blue] vs ' H.name ...
            ' [red] in null(B2)'], 'FontSize', 14);
    end

end
