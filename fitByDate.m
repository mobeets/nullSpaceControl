function D = fitByDate(dtstr, params, nms, plotopts, opts, hypopts)
% 20120525 20120601 20131125 20131205    
    if nargin < 2 || isempty(params)
        params = struct();
    end
    if nargin < 3
        nms = {'kinematics mean', 'habitual', 'cloud-hab'};
    end
    if nargin < 4 || isempty(plotopts) || ~isstruct(plotopts)
        plotopts = struct();
    end
    if nargin < 5 || isempty(opts)
        opts = struct();
    end
    if nargin < 6 || isempty(hypopts)
        hypopts = struct();
    end
    
    D = io.quickLoadByDate(dtstr, params, opts);
    D = pred.fitHyps(D, nms, hypopts);
    D = pred.nullActivity(D, hypopts);
    D = score.scoreAll(D);

    if numel(fieldnames(plotopts)) > 0
        plot.plotAll(D, D.hyps, plotopts, hypopts);
    end
end
