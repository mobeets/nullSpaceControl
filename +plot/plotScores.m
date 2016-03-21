function plotScores(D, nm)
    if nargin < 2
        nm = D.datestr;
    end
    figure;
    subplot(1,3,1); hold on;
    plot.errOfMeans(D.hyps(2:end), nm);
    subplot(1,3,2); hold on;
    plot.covError(D.hyps(2:end), nm, 'covErrorOrient');
    subplot(1,3,3); hold on;
    plot.covError(D.hyps(2:end), nm, 'covErrorShape');
end
