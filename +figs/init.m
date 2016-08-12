
dts = io.getDates();
dts = sort(dts);
dtnms = io.addMnkNmToDates(dts);

clrs = get(gca, 'ColorOrder');
clrs = [clrs; mean(clrs(5:6,:))];
close;

baseClr = [0 0 0];
habClr = clrs(7,:);
cldClr = clrs(1,:);
uncClr = clrs(4,:);
basClr = clrs(8,:);
minClr = clrs(2,:);

% this assumes a fixed 11-name cell array
allHypClrs = [baseClr; habClr; habClr; habClr; ...
    cldClr; cldClr; uncClr; basClr; ...
    minClr; habClr; habClr];

% 6-name cell array
allHypClrs = [baseClr; cldClr; habClr; uncClr; basClr; minClr];
