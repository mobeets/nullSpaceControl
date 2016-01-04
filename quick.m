
d = load('data/20120303simpleData_combined.mat');
d = d.simpleData;

%%

tmp = [];
for ii = 1:numel(d.binTimes)
    tmp = [tmp; d.binTimes{ii}];
end
