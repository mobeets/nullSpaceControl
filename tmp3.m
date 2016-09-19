
% D = io.quickLoadByDate('20131205', struct(), struct('doRotate', false));
[Z,U] = pred.minEnergyFit(D, struct('addSpikeNoise', false));
B = D.blocks(2);
Ys = B.spikes;
Yf = B.latents;
gs = B.thetaActualGrps16;
NBs = B.nDecoder.NulM2;
NBf = B.fDecoder.NulM2;
RBs = B.nDecoder.RowM2;
RBf = B.fDecoder.RowM2;

%%

ix = ~any(isnan(Z),2);
gs = gs(ix);

Ysr = Ys*RBs;
Yfr = Yf*RBf;
Ysr = Ysr(ix,:);
Yfr = Yfr(ix,:);

% [~,~,v] = svd(Yf*NBf);

Z = Z(ix,:);
U = U(ix,:);
Un = U*NBs;
Zn = Z*NBf;%*v;

% decoder = D.simpleData.nullDecoder;
% mu = decoder.spikeCountMean';
% U2 = bsxfun(@plus, U(ix,:), -mu');
% Un2 = U2*NBs;

%%

Yc = Zn;

grps = sort(unique(gs));
clrs = cbrewer('div', 'RdYlGn', numel(grps));
plot.init;

for ii = 1:size(Yc,1)
    cix = grps == gs(ii);
    plot(Yc(ii,1), Yc(ii,2), '.', 'MarkerSize', 25, 'Color', clrs(cix,:));
end

