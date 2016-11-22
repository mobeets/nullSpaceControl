
dts = io.getDates();

dts = sort(dts);
[dtnms, ixMnk] = io.addMnkNmToDates(dts);

clrs = get(gca, 'ColorOrder');
clrs = [clrs; mean(clrs(5:7,:))];
close;

baseClr = [0 0 0];
cldClr = clrs(1,:);
habClr = clrs(2,:);
uncClr = clrs(4,:);
% basClr = [1 0.451 0.702];
basClr = [0.7725 0.1059 0.4902];
minClr = clrs(6,:);
minClr = [0.2078 0.5922 0.5608];

if strcmpi(fitNm, 'allSampling') || strcmpi(fitNm, 'allSampling0')
    allHypClrs = [baseClr; cldClr; habClr; uncClr; basClr; minClr];
elseif strcmpi(fitNm, 'splitIntuitive')
    allHypClrs = [baseClr; uncClr; basClr; minClr; basClr; minClr; uncClr];
elseif strcmpi(fitNm, 'savedFull')
    allHypClrs = [baseClr; habClr; habClr; habClr; ...
        cldClr; cldClr; uncClr; basClr; ...
        minClr; habClr; habClr];
elseif strcmpi(fitNm, 'allHyps') || strcmpi(fitNm, 'allHypsNoIme')    
    allHypClrs = [baseClr; cldClr; habClr; uncClr; basClr; minClr; ...
        basClr; minClr; uncClr];
elseif strcmpi(fitNm, 'allHypsAgain') || strcmpi(fitNm, 'allAutoFit')
    allHypClrs = [baseClr; cldClr; cldClr; habClr; uncClr; basClr; ...
        minClr; basClr; minClr; uncClr];
elseif strcmpi(fitNm, 'allHypsEightKins')
    allHypClrs = [baseClr; cldClr; habClr; uncClr];
end

fopts = struct('doSave', false, 'plotdir', fullfile('+figs', 'output'));

hypNmsShown = {'Habitual-corrected', 'Constant-cloud', ...
    'Uncontrolled-empirical', 'Uncontrolled-uniform', 'Minimal firing', ...
    'Baseline firing', 'Data'};
hypNmsShown_cosyne = {'HC', 'CC', 'UE', 'UU', 'MF', 'BF', 'Data'}; 
hypNmsInternal = {'habitual', 'cloud', 'unconstrained', ...
    'uncontrolled-uniform', 'minimum', 'baseline', 'observed'};
