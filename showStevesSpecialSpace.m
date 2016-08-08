%% load ratio of det(cov)

dts = io.getDates();

angsYesIme = nan(numel(dts),1);
angsNoIme = nan(numel(dts),1);
dtcvYesImeNoRot = nan(numel(dts),1);
dtcvYesIme = nan(numel(dts),1);
dtcvNoIme = nan(numel(dts),1);
for ii = 1:numel(dts)
    
    D = io.quickLoadByDate(dts{ii});
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;
    
    decNm = 'fImeDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    angsYesIme(ii) = tools.angleBetweenMappings(RB1, RB2);
    
    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    RB2 = B2.(decNm).RowM2;
    angsNoIme(ii) = tools.angleBetweenMappings(RB1, RB2);
    
    decNm = 'fImeDecoder';
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    SS0 = (NB2*NB2')*RB1;    
    det1 = det(cov(Y1*SS0));
    det2 = det(cov(Y2*SS0));
    dtcvYesImeNoRot(ii) = det1./det2;
    
    [u,s,v] = svd(SS0);
    SS = SS0*v;
    det1 = det(cov(Y1*SS));
    det2 = det(cov(Y2*SS));
    dtcvYesIme(ii) = det1./det2;
    
    decNm = 'fDecoder';
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    SS0 = (NB2*NB2')*RB1;
    [u,s,v] = svd(SS0);
    SS = SS0*v;
    det1 = det(cov(Y1*SS));
    det2 = det(cov(Y2*SS));
    dtcvNoIme(ii) = det1./det2;    

end

%% bar plot of ratio of det(cov)

dtcv = 1./dtcvYesIme;
plot.init;
bar(1:numel(dts), dtcv, 'FaceColor', 'w');
plot(xlim, [1 1], 'k--');
set(gca, 'FontSize', 14);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 45);
ylabel('det(cov): irrelevant/relevant');

%% compare ratios with and without IME

plot.init;
plot(1./dtcvNoIme(ixMnk), 1./dtcvYesIme(ixMnk), 'r.', 'MarkerSize', 25);
plot(1./dtcvNoIme(~ixMnk), 1./dtcvYesIme(~ixMnk), 'b.', 'MarkerSize', 25);
xlim([0 2]); ylim(xlim);
plot(xlim, ylim, 'k--');
xlabel('det(cov) no ime');
ylabel('det(cov) with ime');
title('irrelevant / relevant');

%% load learning metrics

[Dts, PrtNum, Mnk, PrtType, Lrn, PrfHit] = io.importPatrickLearningMetrics();
Dts = arrayfun(@num2str, Dts, 'uni', 0);
ixDt = ismember(Dts, dts);

%% compare learning to ratio of det(cov)

xs = Lrn(ixDt);
ys = 1./dtcvNoIme;
% ys = 1./dtcvYesIme;

plot.init;
plot(xs(ixMnk), ys(ixMnk), 'r.', 'MarkerSize', 25);
plot(xs(~ixMnk), ys(~ixMnk), 'b.', 'MarkerSize', 25);
xlabel('learning');
ylabel('det(cov), no ime');

%% compare learning to angle between mappings

xs = PrfHit(ixDt);
ys = angsNoIme;

plot.init;
plot(xs(ixMnk), ys(ixMnk), 'r.', 'MarkerSize', 25);
plot(xs(~ixMnk), ys(~ixMnk), 'b.', 'MarkerSize', 25);
xlabel('learning');
ylabel('angle between mappings, no ime');
