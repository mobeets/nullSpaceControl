
dts = io.getDates();
dts = sort(dts);
[dtnms, ixMnk] = io.addMnkNmToDates(dts);

clrs = get(gca, 'ColorOrder');
clrs = [clrs; mean(clrs(5:6,:))];
close;

baseClr = [0 0 0];
habClr = clrs(7,:);
cldClr = clrs(1,:);
uncClr = clrs(4,:);
basClr = clrs(8,:);
minClr = clrs(2,:);

if strcmpi(fitNm, 'allSampling')
    allHypClrs = [baseClr; cldClr; habClr; uncClr; basClr; minClr];
elseif strcmpi(fitNm, 'splitIntuitive')
    allHypClrs = [baseClr; uncClr; basClr; minClr; basClr; minClr; uncClr];
elseif strcmpi(fitNm, 'savedFull')
    allHypClrs = [baseClr; habClr; habClr; habClr; ...
        cldClr; cldClr; uncClr; basClr; ...
        minClr; habClr; habClr];
end

fopts = struct('doSave', false, 'plotdir', fullfile('+figs', 'output'));
