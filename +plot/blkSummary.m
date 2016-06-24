function blkSummary(Blk, NBlk, Y, doScatter, doMean, clr, NB, ix0, doTrans)
    if nargin < 2 || isempty(NBlk)
        NBlk = Blk;
    end
    if nargin < 3 || isempty(Y)
        Y = Blk;
    end
    if nargin < 4
        doScatter = true;
    end
    if nargin < 5
        doMean = true;
    end
    if nargin < 6
        clr = nan;
    end
    if nargin < 7 || isempty(NB)
        NB = NBlk.fDecoder.NulM2;
    end
    if nargin < 8 || isempty(ix0)
        ix0 = true;
    end
    if nargin < 9
        doTrans = false;
    end

    xs = Blk.thetaActualGrps;
    ys = Y.latents*NB;
    grps = Blk.thetaActualGrps;
    
    % ignore nans
    ix = ix0 & ~isnan(sum(ys,2));
    xs = xs(ix); ys = ys(ix,:); grps = grps(ix);

    if doTrans
        cnts = score.thetaCenters();
        plot.nullActivityPerKinematic(ys, xs, cnts, ...
            doScatter, doMean, clr);
    else
        plot.nullActivityPerBasisColumn(xs, ys, grps, doScatter, ...
            doMean, clr);
    end

end
