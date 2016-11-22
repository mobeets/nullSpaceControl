
dts = io.getDates();
% dts = io.getDates(true, false, {'Nelson'});

% nms = {'baseline', 'minimum', 'unconstrained', ...
%     'baseline-sample', 'minimum-sample', 'uncontrolled-uniform'};
% nms = {'habitual', 'cloud', 'unconstrained', ...
%     'baseline', 'minimum', 'uncontrolled-uniform'};
nms = {'habitual', 'cloud', 'cloud-200', 'unconstrained', ...
    'baseline-sample', 'minimum-sample', 'uncontrolled-uniform', ...
    'baseline', 'minimum'};

% nms = {'habitual', 'cloud', 'unconstrained'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps', ...
    'obeyBounds', true, 'boundsType', 'spikes');

hypopts.fitInLatent = false;
hypopts.addSpikeNoise = true;

% fitNm = 'splitIntuitive';
% fitNm = 'allSampling';
% fitNm = 'allHypsNoIme';
% fitNm = 'allHypsEightKins';
% fitNm = 'allHypsAgain';
fitNm = 'allAutoFit_v2';

%%

if strcmp(fitNm, 'splitIntuitive')
    lopts = struct('postLoadFcn', @io.splitIntuitiveBlock);
elseif strcmp(fitNm, 'allIntHalfPert_rand')
    lopts = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, true));
elseif strcmp(fitNm, 'splitPerturbation_rand')
    lopts = struct('postLoadFcn', @(D) io.splitIntuitiveBlock(D, 2, 0.5, false));
else
    lopts = struct('postLoadFcn', @io.makeImeDefault);
end

popts = struct();
pms = struct();

baseDir = fullfile('data', 'fits', fitNm);
if ~exist(baseDir, 'dir')
    mkdir(baseDir);
end

%%

isConfirmed = false;
skipIfExists = false;
for ii = 10:numel(dts) % 27 and 28 failed
    dtstr = dts{ii}
    fnm = fullfile(baseDir, [dtstr '.mat']);
    if ~isConfirmed && exist(fnm, 'file')
        if skipIfExists
            continue;
        end
        reply = input('File exists. Still want to save? ', 's');
        isConfirmed = true;
    end
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    save(fnm, 'D');
end
