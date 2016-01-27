function blkSummaryPredicted(D, H, doRotate, doCompare, doTrans)
    if nargin < 3
        doRotate = false;
    end
    if nargin < 4
        doCompare = false;
    end
    if nargin < 5
        doTrans = false;
    end

    % figure;
    clr1 = [0.2 0.2 0.8];
    clr2 = [0.8 0.2 0.2];

    % project onto axes of maximum variance in observed data
    NB = D.blocks(2).fDecoder.NulM2;
    if doRotate
        [~,~,v] = svd(D.blocks(2).latents*NB);
        NB = NB*v;
    end
    
    if doCompare
        plot.blkSummary(D.blocks(2), [], H, true, true, clr2, NB, ...
            [], doTrans);
        plot.subtitle([H.name ' in null(B2)'], 'FontSize', 14);
    else
        plot.blkSummary(D.blocks(2), [], [], false, true, clr1, NB, ...
            [], doTrans);
        plot.blkSummary(D.blocks(2), [], H, false, true, clr2, NB, ...
            [], doTrans);
        plot.subtitle(['observed [blue] vs ' H.name ...
            ' [red] in null(B2)'], 'FontSize', 14);
    end

end
