function nullActivityOverTrials(D, xnm, nbins, H)
    if nargin < 2
        xnm = 'trial_index';
    end
    if nargin < 3
        nbins = 4;
    end
    if nargin < 4
        H = [];
    end
    doT = true;
    doRotate = true;

    B = D.blocks(2);
    NB = B.fDecoder.NulM2;
    if doRotate
        [~,~,v] = svd(B.latents*NB);
        NB = NB*v;
    end
    
    xs = B.(xnm);
    ts = unique(xs);
    bins = prctile(ts, linspace(0, 100, nbins+1));

    cmap = cbrewer('seq', 'Blues', nbins+2);

    for ii = 1:nbins
        ix = xs >= bins(ii) & xs <= bins(ii+1);
        plot.blkSummary(B, H, [], false, true, cmap(ii+2,:), NB, ix, doT);
    end
    plot.subtitle('observed by trial period [light to dark = early to late]', ...
        'FontSize', 14);

end
