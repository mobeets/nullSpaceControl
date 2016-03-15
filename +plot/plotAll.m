function plotAll(D, Hs, doSave, isMaster, doSolos)
    if nargin < 3
        doSave = false;
    end
    if nargin < 4
        isMaster = false;
    end
    if nargin < 5
        doSolos = true;
    end
    if doSave
        fldr = plot.getFldr(D, isMaster);
    else
        fldr = '';
    end
    
    if doSolos
        for ii = 1:numel(Hs)
            plot.plotHyp(D, Hs(ii), fldr); 
        end
    end
    
    % write out params
    if ~isempty(fldr)
        writetable(struct2table(D.params), fullfile(fldr, 'params.csv'));
    end
    
    % Plot error of means
    fig = figure;
    plot.errOfMeans(Hs, D.datestr);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, 'errOfMeans'), 'png');
    end

    % Plot error of covariance orientation
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorOrient');
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, 'covErrorOrient'), 'png');
    end

    % Plot error of covariance shape
    fig = figure;
    plot.covError(Hs, D.datestr, 'covErrorShape');
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, 'covErrorShape'), 'png');
    end

end
