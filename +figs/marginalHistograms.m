function marginalHistograms(D, hypInds, grpVals, hypClrs)

    if numel(grpVals) == 0
        oneColPerFig = true;
        oneKinPerFig = false;
    else
        oneColPerFig = false;
        oneKinPerFig = true;
    end

    [~,~,fgs] = plot.fitAndPlotMarginals(D, struct('hypInds', hypInds, ...
        'tightXs', true, 'grpsToShow', grpVals, ...
        'grpNm', 'thetaActualGrps16', ...
        'nbins', 40, 'clrs', hypClrs, 'ttl', '', ...
        'oneColPerFig', oneColPerFig, 'oneKinPerFig', oneKinPerFig, ...
        'sameLimsPerPanel', true, 'doFit', true, 'makeMax1', false));

    for kk = 1:numel(fgs)
        txs = findobj(fgs(kk), 'Type', 'Axes');
        lms = cell2mat(arrayfun(@(ii) txs(ii).XLim, ...
            1:numel(txs), 'uni', 0)');
        for jj = 1:numel(txs)
            txs(jj).FontSize = 14;
            txs(jj).YLim = [0 1.2]; % 0.7 1.2
            txs(jj).XLim = [min(lms(:,1)) max(lms(:,2))];
        end
        if numel(grpVals) == 0
            set(fgs(kk), 'Position', [0 0 700 700]);
        else
            set(fgs(kk), 'Position', [0 0 360 700]);
        end
    end

end
