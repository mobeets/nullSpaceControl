function plotScores(D, ttl)
    if nargin < 2
        ttl = D.datestr;
    end
    figure;
    subplot(1,3,1); hold on;
    plot.errOfMeans(D.hyps(2:end), ttl);
    subplot(1,3,2); hold on;
    plot.covError(D.hyps(2:end), ttl, 'covErrorOrient');
    subplot(1,3,3); hold on;
    plot.covError(D.hyps(2:end), ttl, 'covErrorShape');
end
