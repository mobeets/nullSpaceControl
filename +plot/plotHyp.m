function plotHyp(D, H, fldr, doSave, doStick)
    if nargin < 3
        fldr = '';
    end
    if nargin < 4
        doSave = false;
    end
    if nargin < 5
        doStick = false;
    end
    if doSave && isempty(fldr)
        fldr = plot.getFldr(D);
    end
    doRotate = true;
    
    % plot all combos of doSolo and doTranspose
    for doSolo = 0:1
        for doTranspose = 0:1
            fig = figure;
            plot.blkSummaryPredicted(D, H, doRotate, doSolo, doTranspose);
            fnm = getFnm(H.name, fldr, doRotate, doSolo, doTranspose);
            if ~isempty(fldr)
                saveas(fig, fnm, 'png');
            end
        end
    end
    
    % norms by kinematics
    fig = figure; nm = [D.datestr ' Blk2 - ' H.name];
    ths = D.blocks(2).thetas + 180;
    Y1 = D.blocks(2).latents;
    [ys, xs] = plot.valsByKinematics(D, ths, Y1, [], 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.2 0.2 0.8]);
    Y2 = H.latents;
    [ys, xs] = plot.valsByKinematics(D, ths, Y2, [], 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.8 0.2 0.2]);
    [ys, xs] = plot.valsByKinematics(D, ths, Y1, Y2, 8, true, 2);
    plot.byKinematics(xs, ys, nm, [0.2 0.8 0.2]);
    legend({'true', H.name, 'error'});
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, [H.name '_kinNorms']), 'png');
    end
    
    if ~doStick
        return;
    end
    
    % stick plot
    fig = figure;
    plot.stickPlot(D.hyps(1).nullOG(2).zMu, H.null(2).zMu, H.name);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, [H.name '_stick']), 'png');
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
