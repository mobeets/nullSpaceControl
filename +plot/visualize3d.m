function [D,v] = visualize3d(latents, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('showMu', true, 'showPts', true, 'doNull', true, ...
        'doColor', true, 'D', [], 'blockInd', 2, ...
        'markerStr', 'ko', 'grpName', 'thetaGrps', 'showCov', false, ...
        'decoderNm', 'fDecoder');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~isfield(opts, 'mapInd')
        opts.mapInd = opts.blockInd;
    end
    if ~isfield(opts, 'v')
        opts.v = [];
    end
    v = opts.v;

    if isempty(opts.D)
        D = io.quickLoadByDate(opts.dtstr);
    else
        D = opts.D;
    end
    B = D.blocks(opts.blockInd);
    NB2 = D.blocks(opts.mapInd).(opts.decoderNm).NulM2;
    RB2 = D.blocks(opts.mapInd).(opts.decoderNm).RowM2;
    Y = latents;
    
    if opts.doNull
        Y = Y*NB2;
    end
%     if isempty(v)
%         [u,s,v] = svd(Y);
%     end
    if ~isempty(v)
        Y = Y*v;
    end
    
    gs = B.(opts.grpName);
    grps = sort(unique(gs));
    
    set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 18);
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    
    for jj = 1:numel(grps)
        ix = grps(jj) == gs;
        if opts.doColor
            clr = clrs(jj,:);
        else
            clr = 'k';
        end        
        if opts.showPts
            plot3(Y(ix,1), Y(ix,2), Y(ix,3), '.', 'Color', clr);
        end
    end
    if opts.showCov
        for jj = 1:numel(grps)
            ix = grps(jj) == gs;
            clr = clrs(jj,:);
            pts = tools.gauss2dcirc(Y(ix,1:2), 2);
            zs = zeros(size(pts(1,:)));
            plot3(pts(1,:), pts(2,:), zs, '-', 'Color', clr, 'LineWidth', 4);
        end
    end
    markerStr = opts.markerStr;
    if opts.showMu
        for jj = 1:numel(grps)
            ix = grps(jj) == gs;
            clr = clrs(jj,:);
            mu = nanmean(Y(ix,1:3));
            plot3(mu(1), mu(2), mu(3), markerStr, ...
                'MarkerFaceColor', clr, ...
                'MarkerSize', 10);
        end
    end
    
    plot3(0,0,0,'r+','MarkerSize', 10, 'LineWidth', 4);
    axis vis3d;
    title(D.datestr);
end
