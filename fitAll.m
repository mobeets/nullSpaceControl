
nms = {'habitual', 'cloud', 'unconstrained', ...
    'baseline', 'minimum'};
nms = {'cloud'};

hypopts = struct('nBoots', 0, 'obeyBounds', false, ...
    'scoreGrpNm', 'thetaActualGrps16');

fitNm = 'savedFull';

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

isConfirmed = false;
for ii = 1:numel(dts)
    dtstr = dts{ii}    
    fnm = fullfile('data', 'fits', fitNm, [dtstr '.mat']);
    if ~isConfirmed && exist(fnm, 'file')
        reply = input('File exists. Still want to save? ', 's');
        isConfirmed = true;
    end
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    save(fnm, 'D');
end
