function plotAll(D, opts, hopts)
    if nargin < 3
        opts = struct();
    end
    if nargin < 4
        hopts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('doSave', false, 'isMaster', false, ...
        'doSolos', false, 'doTimestampFolder', true, ...
        'errBarNm', 'se', ... % options are ['', 'se', 'std']
        'plotdir', fullfile('plots', D.datestr));
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    if opts.doSave
        fldr = plot.getFldr(opts);
    else
        fldr = '';
    end
    
    % remove observed
    Hs0 = D.score;
    Hs = D.score(~strcmp('observed', {D.hyps.name}));

    % write out params
    if opts.doSave
        ps = tools.setDefaultOptsWhenNecessary(D.params, D.opts);
        writetable(struct2table(ps), fullfile(fldr, 'params.csv'));
    end

    % Plot total errors
    eNms = {'errOfMeans', 'covError', 'covErrorOrient', 'covErrorShape', 'histErr'};
    for ii = 1:numel(eNms)
        fig = figure;
        if strcmp(eNms{ii}, 'histErr')
            Hsc = D.score(~ismember({D.hyps.name}, {'observed', 'zero'}));
        else
            Hsc = Hs;
        end
        plot.barByHyp([Hsc.(eNms{ii})], {Hsc.name}, eNms{ii}, ...
            [Hsc.([eNms{ii} '_se'])]);
        title(D.datestr);
        if opts.doSave
            saveas(fig, fullfile(fldr, [D.datestr '-' eNms{ii}]), 'png');
        end
    end
    
    % Plot errors by kin
    eNms = {'errOfMeans', 'covError', 'covErrorOrient', 'covErrorShape', 'histErr'};
    for ii = 1:numel(eNms)
        fig = figure;
        if strcmp(eNms{ii}, 'histErr')
            Hsc = D.score(~ismember({D.hyps.name}, {'observed', 'zero'}));
        else
            Hsc = Hs;
        end
        plot.errorByKin(Hsc, [eNms{ii} 'ByKin']);
        title(D.datestr);
        if opts.doSave
            saveas(fig, fullfile(fldr, ...
                [D.datestr '-' eNms{ii} 'ByKin']), 'png');
        end
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
