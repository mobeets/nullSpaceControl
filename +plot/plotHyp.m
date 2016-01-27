function plotHyp(D, H, fldr, doSave)
    if nargin < 3
        fldr = '';
    end
    if nargin < 4
        doSave = false;
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
