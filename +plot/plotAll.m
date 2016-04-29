function plotAll(D, Hs, opts, hopts)
    if nargin < 3
        opts = struct();
    end
    if nargin < 4
        hopts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('doSave', false, 'isMaster', false, ...
        'doSolos', false, 'doTimestampFolder', true, ...
        'plotdir', fullfile('plots', D.datestr));
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    if opts.doSave
        fldr = plot.getFldr(opts);
    else
        fldr = '';
    end
    
    % remove observed
    Hs0 = Hs;
    Hs = D.hyps(~strcmp('observed', {D.hyps.name}));

    % write out params
    if opts.doSave
        ps = tools.setDefaultOptsWhenNecessary(D.params, D.opts);
        writetable(struct2table(ps), fullfile(fldr, 'params.csv'));
    end
    
    % Plot error of means
    fig = figure;
    plot.errOfMeans(Hs, D.datestr);
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-errOfMeans']), 'png');
    end
    
    % Plot error of covariance
    fig = figure;
    plot.covError(Hs, D.datestr, 'covError');
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-covError']), 'png');
    end
    
    % Plot error of covariance orientation
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorOrient');
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-covErrorOrient']), 'png');
    end

    % Plot error of covariance shape
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorShape');
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-covErrorShape']), 'png');
    end

    % Plot errors by kin
    fig = figure;
    plot.allErrorByKin(D, Hs);
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-errorByKin']), 'png');
    end
    
    % Plot errors by kin by col
    fig = figure;
    plot.meanErrorByKinByCol(D, Hs);
    if opts.doSave
        saveas(fig, fullfile(fldr, [D.datestr '-errorByKinByCol']), 'png');
    end
    
    % Plot hypotheses
    if opts.doSolos
        for ii = 1:numel(Hs0)
            plot.plotHyp(D, Hs(ii), opts, fldr, hopts);
        end
    end

end
