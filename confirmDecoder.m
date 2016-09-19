
dtstr = '20131205';
params = io.setUnfilteredDefaults();
opts = struct('doRotate', false);

D = io.quickLoadByDate(dtstr, params, opts);
Blk = D.trials;

%%

bind = 2;
ib = Blk.block_index == bind;
dec = D.blocks(bind).fDecoder;
% dec = D.blocks(bind).nDecoder; % aka D.simpleData.nullDecoder.rawSpikes;
% dec = D.simpleData.nullDecoder.normalizedSpikes;

%%


A = dec.M1;
B = dec.M2;
c = dec.M0;

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

    % target position
    cT = Blk.target(find(it, 1, 'first'),:)'; % 1x2

    % cursor position
    cY = Blk.pos(it,:)';
    cV = Blk.vel(it,:)';
    cVp = Blk.velPrev(it,:)';

    % spikes
    cU = Blk.spikes(it,:)';
    if size(Blk.spikes,2) ~= size(B,2)
        cU = Blk.latents(it,:)';
    end

    errs{ii} = nan(size(cY,1),1);
    for jj = 2:size(cY,2)
        x1 = cV(:,jj);
        x0 = cVp(:,jj);
        z1 = cU(:,jj-1);
        x1_h = A*x0 + B*z1 + c;
        errs{ii}(jj) = norm(x1_h - x1);
    end
    
end

% close all;
hold on;
plot(smooth(cell2mat(errs), 100));

%%

Z = D.blocks(bind).latents;
RB = D.blocks(bind).fDecoder.RowM2;
Zr = Z*RB;

Y = D.blocks(bind).spikes;
RBn = D.blocks(bind).nDecoder.RowM2;
Yr = Y*RBn;

plot.init;
subplot(1,2,1); hold on;
plot(Yr(:,1), Yr(:,2), 'k.');
title('row space via spikes');
subplot(1,2,2); hold on;
plot(Zr(:,1), Zr(:,2), 'k.');
title('row space via latents');

%%

NB = D.blocks(1).fDecoder.NulM2;
RB = D.blocks(1).fDecoder.RowM2;
M2 = D.blocks(1).fDecoder.M2';

NBn = D.blocks(1).nDecoder.NulM2;
RBn = D.blocks(1).nDecoder.RowM2;
M2n = D.blocks(1).nDecoder.M2';

%%

Y0 = D.blocks(1).spikes;
Y = Y0;
decoder = D.simpleData.nullDecoder;
mu = decoder.spikeCountMean';
% Y = bsxfun(@plus, Y, -mu');
sigmainv = diag(1./decoder.spikeCountStd);
Y = (bsxfun(@plus, Y', -mu))'*sigmainv;

Z = D.blocks(1).latents;
Dc = D.simpleData.nullDecoder;

disp('-----');

L = decoder.FactorAnalysisParams.L;    
ph = decoder.FactorAnalysisParams.ph;
beta = L'/(L*L'+diag(ph));
M = sigmainv*beta';
% M = beta';
% RBn = M*RB;

subspace(sigmainv*beta'*RB, RBn)
% subspace(RB, NB)
% subspace(RBn, NBn)

Z0 = Y0*M;
Z1 = Y*M;
m0 = max(abs(sum((Y0*RBn).^2,2))); % should be zero
s0 = max(abs(sum((Y*RBn).^2,2))); % should be zero
f0 = max(abs(sum((Z0*RB).^2,2))); % should be zero
g0 = max(abs(sum((Z1*RB).^2,2))); % should be zero
[m0 s0 f0 g0]

Y_noRow = Y*(NBn*NBn');
% Z_noRow = tools.convertRawSpikesToRawLatents(Dc, Y_noRow');
% Y_noRow = (sigmainv*(bsxfun(@plus, Y_noRow', -mu)))';
Z_noRow = Y_noRow*M;
s1 = max(abs(sum((Y_noRow*RBn).^2,2))); % should be zero
f1 = max(abs(sum((Z_noRow*RB).^2,2))); % should be zero
[s1 f1]

Y_noNull = Y*(RBn*RBn'); % Y*M*(RB*RB')*M'
% Z_noNull = tools.convertRawSpikesToRawLatents(Dc, Y_noNull');
Z_noNull = Y_noNull*M;
s2 = max(var(Y_noNull*NBn)); % should be zero
f2 = max(var(Z_noNull*NB)); % should be zero
[s2 f2]


% Y*(RBn*RBn')*NBn
% Y*(RBn*RBn')*sigmainv*beta'*NB
rad2deg(subspace(NBn, sigmainv*beta'*NB))
rad2deg(subspace(NBn, beta'*NB)) % 88x86, 88x8

%%

NBn = D.blocks(1).nDecoder.NulM2;
RBn = D.blocks(1).nDecoder.RowM2;

Y = D.blocks(1).spikes;
decoder = D.simpleData.nullDecoder;
mu = decoder.spikeCountMean';
sigmainv = diag(1./decoder.spikeCountStd);
% Y = (bsxfun(@plus, Y', -mu))'*sigmainv;

sigmainv = diag(1./decoder.spikeCountStd);
L = decoder.FactorAnalysisParams.L;    
ph = decoder.FactorAnalysisParams.ph;
beta = L'/(L*L'+diag(ph));
% M = sigmainv*beta';
M = beta';

Y_noNull = Y*(RBn*RBn'); % Y*M*(RB*RB')*M'
Z_noNull = Y_noNull*M;
% Z_noNull = tools.convertRawSpikesToRawLatents(Dc, Y_noNull');
[u,s,v] = svd(Z_noNull);

NB = v(:,3:10);
RB = v(:,1:2);
[subspace(NBn, RBn) subspace(NB, RB)]

'--------'

Y_noRow = Y*(NBn*NBn');
Z_noRow = Y_noRow*M;
% Z_noRow = tools.convertRawSpikesToRawLatents(Dc, Y_noRow');
s1 = max(abs(sum((Y_noRow*RBn).^2,2))); % should be zero
f1 = max(abs(sum((Z_noRow*RB).^2,2))); % should be zero
[s1 f1]

Y_noNull = Y*(RBn*RBn'); % Y*M*(RB*RB')*M'
Z_noNull = Y_noNull*M;
% Z_noNull = tools.convertRawSpikesToRawLatents(Dc, Y_noNull');
s2 = max(var(Y_noNull*NBn)); % should be zero
f2 = max(var(Z_noNull*NB)); % should be zero
[s2 f2]


%%

NBn = D.blocks(1).nDecoder.NulM2;
RBn = D.blocks(1).nDecoder.RowM2;
NBf = D.blocks(1).fDecoder.NulM2;
RBf = D.blocks(1).fDecoder.RowM2;

Y = D.blocks(1).spikes;
% decoder = D.simpleData.nullDecoder;
% mu = decoder.spikeCountMean';
% sigmainv = diag(1./decoder.spikeCountStd).^2;
% Y = (bsxfun(@plus, Y', -mu))';%*sigmainv;

sigmainv = diag(1./decoder.spikeCountStd);
L = decoder.FactorAnalysisParams.L;    
ph = decoder.FactorAnalysisParams.ph;
beta = L'/(L*L'+diag(ph));
M = sigmainv*beta';
% M = beta';

% '------'
%%

'======='

[~,s,v] = svd(Y);
sum(diag(s) > 1e-5)

disp('discarding spike null space');
Yr = Y*(RBn*RBn');
[~,s,v] = svd(Yr);
sum(diag(s) > 1e-5)

disp('mapping to latents');
Zr = Yr*M;
[~,s,v] = svd(Zr);
nc = sum(diag(s) > 1e-5)

disp('comparing to null space');
rad2deg(subspace(v(:,1:nc), NBf))

disp('comparing to row space');
rad2deg(subspace(v(:,1:nc), RBf))

% NBf = v(:,(nc+1):end);
% RBf = v(:,1:nc);

'------'

[~,s,v] = svd(Y);
sum(diag(s) > 1e-5)

disp('discarding spike row space');
Yn = Y*(NBn*NBn');
[~,s,v] = svd(Yn);
sum(diag(s) > 1e-5)

disp('mapping to latents');
Zn = Yn*M;
[~,s,v] = svd(Zn);
nc = sum(diag(s) > 1e-5)

disp('comparing to row space');
rad2deg(subspace(v(:,1:nc), RBf))

disp('comparing to null space');
rad2deg(subspace(v(:,1:nc), NBf))

'------'

disp('confirming null and row are orthogonal');
[rad2deg(subspace(RBn, NBn)) rad2deg(subspace(RBf, NBf))]

disp('confirming row and latent mapping span the same space');
[rad2deg(subspace(RBn, M*RBf))]

%%

Y = rand(1000, 3);

% NBn = [1 0 0; 0 1 0]';
% RBn = [0 0 1]';
% M = [0.5 0.5 0; 0 0 1]';
% NBf = [1 0]';
% RBf = [0 1]';

% B = [-0.5 0.3 1]';
% [NBn, RBn] = tools.getNulRowBasis(B');
% % RBn = B;
% M = [RBn'; 0.2 -0.5 1]';
% [u,s,v] = svd(M', 'econ');
% M = v;
% RB = (Y*M)\(Y*RBn);
% NB = (RB'*[0 1; -1 0])'; % find vector orthogonal to RB

RB = [1 -0.2]';
NB = (RB'*[0 1; -1 0])'; % find vector orthogonal to RB
B = [RB NB];
M = [1 0 0; 0 1 0]';
RBn = M*RB;
NBn = [M*NB [0 0 1]'];

% [NBn, RBn] = tools.getNulRowBasis(B');
% % RBn = B;
% M = [RBn'; 0.2 -0.5 1]';
% [u,s,v] = svd(M', 'econ');
% M = v;
% RB = (Y*M)\(Y*RBn);


[rad2deg(subspace(RBn, M)) rad2deg(subspace(NBn, M)) ...
    rad2deg(subspace(NB, RB)) rad2deg(subspace(NBn, RBn))]

[max((Y*RBn - (Y*M)*RB)) ...
    max(Y*(RBn*RBn')*NBn) ...
    max((Y*(RBn*RBn')*M)*NB) ...
    max(Y*(NBn*NBn')*RBn) ...
    max((Y*(NBn*NBn')*M)*RB)]

