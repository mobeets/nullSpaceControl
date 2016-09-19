%% load

dtstr = '20131205';
params = io.setUnfilteredDefaults();
opts = struct('doRotate', false);

D = io.quickLoadByDate(dtstr, params, opts);
Blk = D.trials;

%% init

bind = 1;
ib = Blk.block_index == bind;

prms = D.simpleData.nullDecoder;
fa = prms.FactorAnalysisParams;
beta = prms.normalizedSpikes.beta;
[L,s,v]= svd(fa.L, 'econ');

nsps_dec = prms.normalizedSpikes;
usps_dec = prms.rawSpikes;
sps_dec = D.blocks(bind).nDecoder;
lts_dec = D.blocks(bind).fDecoder;

[nsps_dec.NulM2, nsps_dec.RowM2] = tools.getNulRowBasis(nsps_dec.M2);

%% verify spikes to latents

sps = Blk.spikes(ib,:);
lts = Blk.latents(ib,:);

sps_nrmf = @(sps) bsxfun(@plus, sps, -prms.spikeCountMean)*diag(1./prms.spikeCountStd);
sps_nrm = sps_nrmf(sps);
lts2 = sps_nrm*beta';
assert(max(abs(sum((lts - lts2).^2,2))) < eps);

%% verify spike/latents mapping

dec = sps_dec;
% dec = lts_dec;

A = dec.M1;
B = dec.M2;
c = dec.M0;
if size(B,2) == size(Blk.latents,2)
    sps = Blk.latents;
else
    sps = Blk.spikes;
end
% sps = sps_nrmf(sps);

ts = Blk.trial_index;
trs = sort(unique(ts(ib)));
ntrs = numel(trs);
errs = cell(ntrs,1);

for ii = 1:ntrs
    it = (ts == trs(ii)) & ib;

    % ensure all times are accounted for; remove first 6 time-points
    tms = Blk.time(it);
    ntms = max(tms);        
    assert(all(sort(tms)' == 1:ntms));
    it = Blk.time >= 7 & it;

    % target/cursor positions and spikes
    cT = Blk.target(find(it, 1, 'first'),:)'; % 1x2
    cY = Blk.pos(it,:)';
    cV = Blk.vel(it,:)';
    cVp = Blk.velPrev(it,:)';
    cU = sps(it,:)';

    errs{ii} = nan(size(cY,1),1);
    for jj = 2:(size(cY,2)-1)
        x1 = cV(:,jj);
        x0 = cVp(:,jj);
        z1 = cU(:,jj-1);
        x1_h = A*x0 + B*z1 + c;
        errs{ii}(jj) = norm(x1_h - x1);
    end
    
end

assert(max(abs(cell2mat(errs))) < 1e-4);

% plot.init; plot(smooth(cell2mat(errs), 100));

%% verify nul/row space in spikes and latents

NBs = nsps_dec.NulM2;
RBs = nsps_dec.RowM2;
% RBs = nsps_dec.M2';
NBf = lts_dec.NulM2;
RBf = lts_dec.RowM2;
% RBf = lts_dec.M2';

% check orthogonal
assert(max(max(abs(NBs'*RBs))) < 1e-5);
assert(max(max(abs(NBf'*RBf))) < 1e-5);

%% confirm overlap of spaces

% sps_dec failures: 4, 5, 9
% nsps_dec failures: 4, 5

% subspace(beta', nsps_dec.M2')
% subspace(beta', sps_dec.M2')
subspace(beta', RBs)
% subspace(RBf, beta*RBs)
subspace((RBs*RBs')*beta'*RBf, RBs)
subspace(beta'*RBf, RBs)
% subspace(nsps_dec.M2*beta', lts_dec.M2)
% subspace(RBs'*beta', RBf')

% verify that spike and latent row spaces are the same
assert(subspace(nsps_dec.M2*beta', lts_dec.M2) < 1e-5, '1');
assert(subspace(beta', nsps_dec.M2') < 1e-5, '1a');

[~,s1,v1] = svd(RBs*RBs');
nd1 = sum(diag(s1) > 1e-5);
assert(rad2deg(subspace(v1(:,1:nd1), RBs)) < 1e-5, '2');
assert(abs(rad2deg(subspace(v1(:,1:nd1), NBs)) - 90) < 1e-5, '3');

[~,s2,v2] = svd((RBs*RBs')*beta');
nd2 = sum(diag(s2) > 1e-5);
assert(rad2deg(subspace(v2(:,1:nd2), RBf)) < 1e-5, '4');
assert(abs(rad2deg(subspace(v2(:,1:nd2), NBf)) - 90) < 1e-5, '5');

[~,s3,v3] = svd(NBs*NBs');
nd3 = sum(diag(s3) > 1e-5);
assert(rad2deg(subspace(v3(:,1:nd3), NBs)) < 1e-5, '6');
assert(abs(rad2deg(subspace(v3(:,1:nd3), RBs)) - 90) < 1e-5, '7');

[~,s4,v4] = svd((NBs*NBs')*beta');
nd4 = sum(diag(s4) > 1e-5);
assert(rad2deg(subspace(v4(:,1:nd4), NBf)) < 1e-5, '8');
assert(abs(rad2deg(subspace(v4(:,1:nd4), RBf)) - 90) < 1e-5, '9');

%% confirm things don't leak over

sps = Blk.spikes(ib,:);
sps = sps_nrmf(sps);

beta = prms.normalizedSpikes.beta;
[u,s,v] = svd(beta', 'econ');
beta = u';

Yc = (sps*(RBs*RBs'))*NBs;
norm(nanvar(Yc))

Yc = (sps*(RBs*RBs'))*(beta'*beta)*NBs; % NOT ZERO
norm(nanvar(Yc))

Yc = ((sps*(RBs*RBs'))*beta')*NBf; % NOT ZERO
nanvar(Yc)

Yc = (sps*(NBs*NBs'))*RBs;
nanvar(Yc)

Yc = ((sps*(NBs*NBs'))*(beta'*beta))*RBs; % NOT ZERO
nanvar(Yc)

Yc = ((sps*(NBs*NBs'))*beta')*RBf;
nanvar(Yc)

Yc1 = ((sps*(NBs*NBs'))*beta')*NBf;
Yc2 = (sps*beta')*NBf;
max(abs(sum((Yc1 - Yc2).^2,2))) % NOT ZERO

%% confirm things don't leak over

ixS = ~any(isnan(Blk.spikes),2);
ixL = ~any(isnan(Blk.latents),2);
sps = Blk.spikes(ib&ixS,:);
lts = Blk.latents(ib&ixL,:);

Z_noNull = sps*(RBs*RBs')*beta'*NBf;
Z_noRow = sps*(NBs*NBs')*beta'*RBf;

assert(max(nanvar(Z_noRow)) < 1e-5);
assert(max(nanvar(Z_noNull)) < 1e-5);

%%

sps = Blk.spikes(ib,:);
sps_nrm = bsxfun(@plus, sps, -prms.spikeCountMean)*diag(1./prms.spikeCountStd);

Yr = sps*RBs;
Zr = lts*RBf;

Yr = sps*(RBs*RBs');
Zr = lts*(RBf*RBf');

Yr = (sps*((RBs*RBs')*beta'))*NBf;
Zr = (lts*(RBf*RBf'))*NBf;
ix = ~any(isnan([Yr Zr]),2);
[A,B,R,U,V,stats] = canoncorr(Yr(ix,:),Zr(ix,:));
max(abs(sum((U - V).^2,2)))
% stats

Yr = sps*((RBs*RBs')*beta');
Zr = lts*(RBf*RBf');
ix = ~any(isnan([Yr Zr]),2);
[A,B,R,U,V,stats] = canoncorr(Yr(ix,:),Zr(ix,:));
max(abs(sum((U - V).^2,2)))
% stats

Yr = sps*((NBs*NBs')*beta')*RBf;
Zr = lts*(NBf*NBf')*RBf;
ix = ~any(isnan([Yr Zr]),2);
[A,B,R,U,V,stats] = canoncorr(Yr(ix,:),Zr(ix,:));
max(abs(sum((U - V).^2,2)))
% stats

%%

plot.init; plot(Yr(:,1), Yr(:,2), '.')
plot.init; plot(Zr(:,1), Zr(:,2), 'r.')
