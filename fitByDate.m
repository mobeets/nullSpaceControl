function D = fitByDate(dtstr, plotArgs, params, nms)
% 20120525 20120601 20131125 20131205
    if nargin < 2
        plotArgs = [false false false]; % doSave, isMaster, doSolos
    end
    if nargin < 3
        params = struct();
    end
    if nargin < 4
        nms = {'kinematics mean', 'habitual', 'cloud-hab'};
    end
    D = io.quickLoadByDate(dtstr, params);    
    D = pred.fitHyps(D, nms);
    D = pred.nullActivity(D);
    D = score.scoreAll(D);

    if ~isempty(plotArgs)
        plot.plotAll(D, D.hyps(2:end), plotArgs(1), plotArgs(2), plotArgs(3));
    end
end
