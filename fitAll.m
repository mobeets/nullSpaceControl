
dts = io.getDates();

nms = {'habitual', 'cloud', 'unconstrained', ...
    'baseline', 'minimum', 'uncontrolled-uniform'};
nms = {'habitual', 'cloud', 'unconstrained', ...
    'baseline-sample', 'minimum-sample'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16', ...
    'obeyBounds', true, 'boundsType', 'spikes');

fitNm = 'allSampling';

%%

if strcmp(fitNm, 'savedFull') || strcmp(fitNm, 'allSampling')
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

baseDir = fullfile('data', 'fits', fitNm);
if ~exist(baseDir, 'dir')
    mkdir(baseDir);
end

isConfirmed = false;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    fnm = fullfile(baseDir, [dtstr '.mat']);
    if ~isConfirmed && exist(fnm, 'file')
        reply = input('File exists. Still want to save? ', 's');
        isConfirmed = true;
    end
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    save(fnm, 'D');
end
