function D = fitByDate(dtstr, params, nms, plotOpts, opts)
% 20120525 20120601 20131125 20131205    
    if nargin < 2 || isempty(params)
        params = struct();
    end
    if nargin < 3
        nms = {'kinematics mean', 'habitual', 'cloud-hab'};
    end
    if nargin < 4 || isempty(plotOpts) || ~isstruct(plotOpts)
        plotOpts = struct('doPlot', false);
    end
    if nargin < 5
        opts = struct();
    end    
    
    D = io.quickLoadByDate(dtstr, params, opts);    
    D = pred.fitHyps(D, nms);
    D = pred.nullActivity(D);
    D = score.scoreAll(D);

    defPlotOpts = struct('doPlot', true, 'doSave', true, ...
        'isMaster', false, 'doSolos', false);
    plotOpts = tools.setDefaultOptsWhenNecessary(plotOpts, defPlotOpts);
    if plotOpts.doPlot
        plot.plotAll(D, D.hyps(2:end), ...
            plotOpts.doSave, plotOpts.isMaster, plotOpts.doSolos);
    end
end
