function blkSummary(Blk, NBlk, Y, doScatter, doMean, clr)
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

    xs = Blk.thetas + 180;    
    NB = NBlk.fDecoder.NulM2;
    ys = Y.latents*NB;
    grps = Blk.targetAngle;

    plot.nullActivityPerBasisColumn(xs, ys, grps, doScatter, doMean, clr);

end
