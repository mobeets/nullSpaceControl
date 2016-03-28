function hypErrorsByTime(dtstr, nms, popts, hypopts, extraNm)
    if nargin < 2 || isempty(nms)
        nms = {'kinematics mean', 'cloud-hab', 'unconstrained'};
    end
    if nargin < 3 || isempty(popts)
        popts = struct('doSave', false);
    end
    if nargin < 4 || isempty(hypopts)
        hypopts = struct('decoderNm', 'fDecoder');
    end
    if nargin < 5
        extraNm = 'trial_length';
    end

    binSz = 100; binSkp = binSz/2; binNm = 'trial_index';
    % binSz = 15; binSkp = 15; binNm = 'angError';
    % binSz = 25; binSkp = binSz/2; binNm = 'time';
        
    params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360);
    D = fitByDate(dtstr, params, nms, [], [], hypopts);
    
    xs1 = min(D.blocks(2).(binNm)); xs2 = max(D.blocks(2).(binNm));
%     xs1 = -120; xs2 = 120;
    tbins = xs1:binSkp:(xs2-binSz);
    
    popts = plot.hypothesisErrorByTime(D, binNm, tbins, ...
        binSz, false, popts, hypopts, extraNm);
    popts = plot.hypothesisErrorByTime(D, binNm, tbins, ...
        binSz, true, popts, hypopts, extraNm);

end
