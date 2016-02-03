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
    
    close all;
    
    if doSolos
        for ii = 1:numel(Hs)
            plot.plotHyp(D, Hs(ii), fldr); 
        end
    end
    
    % Plot error of means
    fig = figure;
    plot.errOfMeans(Hs);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, 'errOfMeans'), 'png');
    end

    % Plot covariance ratios
    fig = figure;
    plot.covRatio(Hs);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, 'covRatio'), 'png');
    end

end
