function marginalHistograms(D, hypInds, grpVals, hypClrs, opts)
    if nargin < 5
        opts = struct('showAll', false, 'doSave', false);
    end

    if opts.showAll
        oneColPerFig = false;
        oneKinPerFig = false;
        tag = 'all';
        ymx = 0.9;
        fntsz = 8;
    elseif numel(grpVals) == 0
        oneColPerFig = true;
        oneKinPerFig = false;
        tag = 'byGrp';
        ymx = 0.9;
        fntsz = 8;
    else
        oneColPerFig = false;
        oneKinPerFig = true;
        tag = 'byKin';
        ymx = 0.7;
        fntsz = 10;
    end

    [~,~,fgs] = plot.fitAndPlotMarginals(D, struct('hypInds', hypInds, ...
        'tightXs', true, 'grpsToShow', grpVals, ...
        'grpNm', 'thetaActualGrps16', ...
        'nbins', 20, 'clrs', hypClrs, 'ttl', '', ...
        'oneColPerFig', oneColPerFig, 'oneKinPerFig', oneKinPerFig, ...
        'sameLimsPerPanel', true, 'doFit', true, 'makeMax1', false));

    if opts.showAll
        wd = 2000; ht = 2000;
    elseif numel(grpVals) == 0
        wd = 200; ht = 850;
    else
%         wd = 360; ht = 700;
        ht = 150; wd = 1250;
    end
    
    for kk = 1:numel(fgs)
        txs = findobj(fgs(kk), 'Type', 'Axes');
        lms = cell2mat(arrayfun(@(ii) txs(ii).XLim, ...
            1:numel(txs), 'uni', 0)');
        for jj = 1:numel(txs)
            txs(jj).FontSize = fntsz;
            txs(jj).YLim = [0 ymx];
            txs(jj).XLim = [min(lms(:,1)) max(lms(:,2))];
        end        
        
        set(fgs(kk), 'PaperUnits', 'inches');
        set(fgs(kk), 'Position', [0 0 wd ht]);
        set(fgs(kk), 'PaperPosition', [0 0 wd/100 ht/100]);
        
        if opts.doSave
            nm = ['margHist_' tag '-' num2str(kk)];
            fignm = fullfile(opts.plotdir, [nm '.png']);
            saveas(fgs(kk), fignm, 'png');
        end
    end

end
