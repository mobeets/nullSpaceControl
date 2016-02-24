function trialMetricsByKinematics(B, fldr, nm)
    if nargin < 2
        fldr = '';
    end
    if nargin < 3
        nm = '';
    end

    xs = B.thetas;
    cnts = score.thetaCenters(8);

    Ys = {B.spd; abs(B.angError); B.angError};
    Ynm = {'speed', 'error', 'bias'};
    clrs = cbrewer('qual', 'Set2', numel(Ynm));

    fig = figure;
    for ii = 1:numel(Ys)
        ys = score.avgByThetaGroup(xs, Ys{ii}, cnts);
        if strcmp(Ynm{ii}, 'bias') && all(ys < 0)
            ys = -ys;
        end
%         ys = ys./max(abs(ys));
        plot.byKinematics(cnts, ys, Ynm{ii}, ...
            clrs(ii,:), 'value');
    end
    legend(Ynm);
    ylim([0 1.2]);
    figNm = nm;
    title(figNm);
    if ~isempty(fldr)
        saveas(fig, fullfile(fldr, figNm), 'png');
    end

end
