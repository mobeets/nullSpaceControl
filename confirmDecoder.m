
bind = 1;
dtstr = '20120601';
params = io.setUnfilteredDefaults();
opts = struct('doRotate', false);

D = io.quickLoadByDate(dtstr, params, opts);
Blk = D.trials;
ib = Blk.block_index == bind;

%%

dec = D.blocks(bind).nDecoder; % aka D.simpleData.nullDecoder.rawSpikes;
% dec = D.simpleData.nullDecoder.normalizedSpikes;

A = dec.M1;
B = dec.M2;
c = dec.M0;

%%

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
