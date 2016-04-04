
D = io.quickLoadByDate('20120525');
B1 = D.blocks(1);
B2 = D.blocks(2);
Y = B2.latents;
NB = B2.fDecoder.NulM2;
RB = B2.fDecoder.RowM2;

%%

YN = Y*NB;
YR = Y*RB;
X0 = YN(1:end-1,:);
X1 = [YR(1:end-1,:) YR(2:end,:)];

ts = B2.trial_index;
ixGood = ts(2:end) == ts(1:end-1);
X0 = X0(ixGood,:);
X1 = X1(ixGood,:);

%%

figure; set(gcf, 'color', 'w');
hold on; set(gca, 'FontSize', 14);
vs = [];
for ii = 1:8
    vs = [vs; corr(X0(:,ii), X1)];
end
plot(vs(:,1), 'k');
plot(vs(:,2), 'k');
plot(vs(:,3));
plot(vs(:,4));
