function plotAll(D, Hs, opts)
    if nargin < 3
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('doSave', false, 'isMaster', false, ...
        'doSolos', false, 'doTimestampFolder', true, ...
        'plotdir', fullfile('plots', D.datestr));
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    fldr = plot.getFldr(opts);

    % write out params
    if opts.doSave
        writetable(struct2table(D.params), fullfile(fldr, 'params.csv'));
    end
    
    % Plot error of means
    fig = figure;
    plot.errOfMeans(Hs, D.datestr);
    if opts.doSave
        saveas(fig, fullfile(fldr, 'errOfMeans'), 'png');
    end

    % Plot error of covariance orientation
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorOrient');
    if opts.doSave
        saveas(fig, fullfile(fldr, 'covErrorOrient'), 'png');
    end

    % Plot error of covariance shape
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorShape');
    if opts.doSave
        saveas(fig, fullfile(fldr, 'covErrorShape'), 'png');
    end
    
    % Plot hypotheses
    if opts.doSolos
        for ii = 1:numel(Hs)
            plot.plotHyp(D, Hs(ii), opts, fullfile(fldr, 'hypScores')); 
        end
    end

end
