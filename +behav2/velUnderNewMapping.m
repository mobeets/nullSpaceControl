function velUnderNewMapping(Blk, dec)

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
    trs = sort(unique(ts));
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
end
