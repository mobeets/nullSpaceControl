
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

NBn = D.blocks(1).nDecoder.NulM2;
RBn = D.blocks(1).nDecoder.RowM2;

%%

Y = D.blocks(1).spikes;
% decoder = D.simpleData.nullDecoder;
% mu = decoder.spikeCountMean';
Y = bsxfun(@plus, Y, -mu');
% sigmainv = diag(1./decoder.spikeCountStd');
% Y = (sigmainv*(bsxfun(@plus, Y', -mu)))';

Z = D.blocks(1).latents;
Dc = D.simpleData.nullDecoder;

disp('-----');

L = decoder.FactorAnalysisParams.L;    
ph = decoder.FactorAnalysisParams.ph;
beta = L'/(L*L'+diag(ph));
sigmainv = diag(1./decoder.spikeCountStd');
M = sigmainv'*beta';
RBn = M*RB;

Y_noRow = Y*(NBn*NBn');
% Z_noRow = tools.convertRawSpikesToRawLatents(Dc, Y_noRow');
Z_noRow = Y_noRow*M;
s1 = max(abs(sum((Y_noRow*RBn).^2,2))); % should be zero
f1 = max(abs(sum((Z_noRow*RB).^2,2))); % should be zero
[s1 f1]

Y_noNull = Y*(RBn*RBn'); % Y*M*(RB*RB')*M'
% Z_noNull = tools.convertRawSpikesToRawLatents(Dc, Y_noNull');
Z_noNull = Y_noNull*M;
s2 = max(abs(sum((Y_noNull*NBn).^2,2))); % should be zero
f2 = max(abs(sum((Z_noNull*NB).^2,2))); % should be zero
[s2 f2]
