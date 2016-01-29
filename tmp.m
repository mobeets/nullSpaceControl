
B = D.blocks(2);
xs = B.thetas + 180;
cnts = score.thetaCenters(8);

Ys = {B.spd; abs(B.angError); B.angError};
Ynm = {'speed', 'error', 'bias'};
clrs = cbrewer('qual', 'Set2', numel(Ynm));

figure;
for ii = 1:numel(Ys)
    ys = score.avgByThetaGroup(xs, Ys{ii}, cnts);    
    plot.byKinematics(cnts, ys./max(abs(ys)), Ynm{ii}, clrs(ii,:), 'value');
end
legend(Ynm);
ylim([0 1.2]);
title([D.datestr ' - difficulty metrics (unfiltered)']);
