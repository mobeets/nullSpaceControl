function fgs = marginalHistograms(D, hypInds, grpVals, hypClrs, dimInds, opts, popts)
    if nargin < 5
        dimInds = [];
    end
    if nargin < 6
        opts = struct('showAll', false, 'doSave', false, ...
            'ext', 'pdf', 'nameFcn', @(ii) ['margHist_' num2str(ii)]);
    end
    if nargin < 7
        popts = struct();
    end

    if opts.showAll
        oneColPerFig = false;
        oneKinPerFig = false;
        tag = 'all';
        defopts = struct('FontName', 'Helvetica', 'FontSize', 12, ...
            'width', 6, 'height', 10, 'margin', 0.25, 'LineWidth', 1, ...
            'yMax', 0.6, 'dimInds', 1:3);
        
    elseif numel(grpVals) == 0
        oneColPerFig = true;
        oneKinPerFig = false;
        tag = 'byGrp';
        defopts = struct('FontName', 'Helvetica', 'FontSize', 12, ...
            'width', 8.5, 'height', 8.5, 'margin', 0.25, ...
            'LineWidth', 1, 'yMax', 0.5, 'dimInds', []);
    else
        oneColPerFig = false;
        oneKinPerFig = true;
        tag = 'byKin';
        defopts = struct('FontName', 'Helvetica', 'FontSize', 10, ...
            'width', 12.5, 'height', 1.5, 'margin', 0.25, ...
            'LineWidth', 0.5, 'yMax', 0.7, 'dimInds', []);
    end
    popts = tools.setDefaultOptsWhenNecessary(popts, defopts);

    [~,~,fgs] = plot.fitAndPlotMarginals(D, struct('hypInds', hypInds, ...
        'tightXs', true, 'grpsToShow', grpVals, ...
        'grpNm', 'thetaActualGrps16', ...
        'nbins', 20, 'clrs', hypClrs, 'ttl', '', ...
        'oneColPerFig', oneColPerFig, 'oneKinPerFig', oneKinPerFig, ...
        'sameLimsPerPanel', true, 'doFit', true, 'makeMax1', false, ...
        'dimInds', dimInds, 'LineWidth', popts.LineWidth, ...
        'includeBlk1', opts.includeBlk1));
    
    for kk = 1:numel(fgs)
        txs = findobj(fgs(kk), 'Type', 'Axes');
        lms = cell2mat(arrayfun(@(ii) txs(ii).XLim, ...
            1:numel(txs), 'uni', 0)');
        for jj = 1:numel(txs)
            if jj == numel(txs) && numel(fgs) == 1 % don't show angle
                txs(jj).XLabel.String = 'Activity level';
                txs(jj).YLabel.String = ['Frequency ' txs(jj).YLabel.String];
            end
            txs(jj).FontSize = popts.FontSize;
            txs(jj).FontName = popts.FontName;
            txs(jj).YLim = [0 popts.yMax];
            txs(jj).XLim = [min(lms(:,1)) max(lms(:,2))];
            txs(jj).XTick = 0;
            txs(jj).XTickLabel = '';
            txs(jj).TickDir = 'out';
            txs(jj).TickLength = [0.05 0];
%             txs(jj).LineWidth = popts.LineWidth;
        end        
        
        figs.setPrintSize(fgs(kk), popts.width, popts.height, popts.margin);
        
        if opts.doSave
            fignm = fullfile(opts.plotdir, opts.nameFcn(kk));
            export_fig(fgs(kk), fignm, ['-' opts.ext]);
%             saveas(fgs(kk), fignm, opts.ext);
        end
    end

end
