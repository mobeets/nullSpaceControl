
nms = {'habitual', 'pruning', 'pruning-1', 'cloud', 'cloud-og', ...
    'voltional', 'mean shift prune', 'mean shift', 'unconstrained', ...
    'baseline', 'minimum'};

hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'thetaActualGrps');

fitNm = 'splitPerturbation_rand';

if strcmp(fitNm, 'savedFull')
    lopts = struct('postLoadFcn', @io.makeImeDefault);
elseif strcmp(fitNm, 'splitIntuitive')
    lopts = struct('postLoadFcn', @io.splitIntuitiveBlock);
elseif strcmp(fitNm, 'allIntHalfPert_rand')
    lopts = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, true));
elseif strcmp(fitNm, 'splitPerturbation_rand')
    lopts = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, false));
end

popts = struct();
pms = struct();
dts = io.getDates();

for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    fnm = fullfile('data', 'fits', fitNm, [dtstr '.mat']);
    if exist(fnm, 'file')
        reply = input('File exists. Still want to save? ', 's');
    end
    save(fnm, 'D');
end
