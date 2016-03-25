
dts = io.getDates();
nms = {'habitual', 'cloud-hab', 'volitional', 'unconstrained'};
Hs = cell(numel(dts),2);
for ii = 1:numel(dts)
    D = fitByDate(dts{ii}, [], nms);
    
end
