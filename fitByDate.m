function D = fitByDate(dtstr, params, nms, plotopts, opts, hypopts)
% 20120525 20120601 20131125 20131205    
    if nargin < 2 || isempty(params)
        params = struct();
    end
    if nargin < 3
        nms = {'true', 'zero', 'habitual', 'cloud-hab'};
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
    if ~isfield(hypopts, 'nBoots')
        hypopts.nBoots = 0;
    end
    
    D = io.quickLoadByDate(dtstr, params, opts);
    for ii = 1:hypopts.nBoots+1
        D = pred.fitHyps(D, nms, hypopts);
        D = score.scoreAll(D, hypopts);
    end
    
    if numel(fieldnames(plotopts)) > 0
        plot.plotAll(D, plotopts, hypopts);
    end
end

