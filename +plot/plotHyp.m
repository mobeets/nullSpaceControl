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
    fig = figure;
    plot.errorByKinematics(D, H, H.name, 16);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, [H.name '_kinErr']), 'png');
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
