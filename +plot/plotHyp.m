function plotHyp(D, H, opts, fldr)
    if nargin < 3
        opts = struct();
    end
    if nargin < 4
        fldr = '';
    end
    if opts.doSave && isempty(fldr)
        fldr = plot.getFldr(opts);
    end
    assert(isa(opts, 'struct'));
    defopts = struct('doSave', false, 'doRotate', true, 'doStick', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if ~exist(fldr, 'dir')
        mkdir(fldr);
    end

    % plot all combos of doSolo and doTranspose
    disp('plot - combos');
    NB = D.blocks(2).fDecoder.NulM2;
    if opts.doRotate
        [~,~,v] = svd(D.blocks(2).latents*NB);
        NB = NB*v;
    end
    
    disp('plot - 1');
    for doSolo = 0:1
        for doTranspose = 0:1
            fig = figure;
            plot.blkSummaryPredicted(D, H, opts.doRotate, doSolo, doTranspose, NB);
            fnm = getFnm(H.name, fldr, opts.doRotate, doSolo, doTranspose);
            if opts.doSave
                saveas(fig, fnm, 'png');
            end
        end
    end
    
    disp('plot - norms');
    % norms by kinematics
    fig = figure; nm = [D.datestr ' Blk2 - ' H.name];
    ths = D.blocks(2).thetas;
    Y1 = D.blocks(2).latents;
    [ys, xs] = plot.valsByKinematics(D, ths, Y1, [], 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.2 0.2 0.8]);
    Y2 = H.latents;
    [ys, xs] = plot.valsByKinematics(D, ths, Y2, [], 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.8 0.2 0.2]);
    [ys, xs] = plot.valsByKinematics(D, ths, Y1, Y2, 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.2 0.8 0.2]);
    legend({'true', H.name, 'error'});
    if opts.doSave
        saveas(fig, fullfile(fldr, [H.name '_kinNorms']), 'png');
    end
    
    if opts.doStick
        disp('plot - sticks');
        % stick plot
        fig = figure;
        plot.stickPlot(D.hyps(1).nullOG(2).zMu, H.null(2).zMu, H.name);
        if opts.doSave
            saveas(fig, fullfile(fldr, [H.name '_stick']), 'png');
        end
    end

end

function fnm = getFnm(nm, fldr, doRotate, doSolo, doTranspose)

    ext = '';
    if doSolo
        ext = [ext '_pts'];
    end
    if doRotate
        ext = [ext '_svd'];
    end
    if doTranspose
        ext = [ext '_kin'];
    end
    fnm = fullfile(fldr, [nm ext]);

end
