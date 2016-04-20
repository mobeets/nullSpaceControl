
opts = struct('doNull', true, 'blockInd', 2, 'mapInd', 2, ...
    'grpName', 'targetAngle');
opts1 = opts; opts1.blockInd = 1; opts1.mapInd = 1;

figure; hold on;
fcn = @(Y) det(cov(Y));
[vs, grps] = tools.valsByGrp(D, fcn, opts);
[vs1, ~] = tools.valsByGrp(D, fcn, opts1);
plot.singleValByGrp(vs, grps, [], [], struct('LineMarkerStyle', 'b:'));
plot.singleValByGrp(vs1, grps, [], [], struct('LineMarkerStyle', 'r:'));
ylabel(func2str(fcn));
title(D.datestr);

figure; hold on;
fcn = @(Y) mean(sqrt(sum(Y.^2,2)));
[vs, grps] = tools.valsByGrp(D, fcn, opts);
[vs1, grps1] = tools.valsByGrp(D, fcn, opts1);
plot.singleValByGrp(vs, grps, [], [], struct('LineMarkerStyle', 'b:'));
plot.singleValByGrp(vs1, grps, [], [], struct('LineMarkerStyle', 'r:'));
ylabel(func2str(fcn));
title(D.datestr);
