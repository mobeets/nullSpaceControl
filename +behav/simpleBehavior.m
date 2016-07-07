function [vs, grps] = simpleBehavior(dtstr, behNm, grpNm, doPlot)
    if nargin < 4
        doPlot = true;
    end

    keepCorrects = ismember(behNm, {'isCorrect'});
    keepTrials = ismember(behNm, {'progress'});
    
    ps = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', ~keepCorrects);
    D = io.quickLoadByDate(dtstr, ps);

    ps0 = io.setBlockStartTrials(dtstr);
    shufTr = ps0.START_SHUFFLE;

    B1 = D.blocks(1);
    B2 = D.blocks(2);
    gs1 = B1.(grpNm);
    gs2 = B2.(grpNm);
    grps = sort(unique(gs1(~isnan(gs1))));

    beh1 = B1.(behNm);
    beh2 = B2.(behNm);

    vs = nan(numel(grps), 3);
    for ii = 1:numel(grps)
        ix1 = gs1 == grps(ii);
        ix2 = gs2 == grps(ii);
        ixs = B2.trial_index > shufTr;

        vsBase = beh1(ix1);
        vsPreLearn = beh2(ix2 & ~ixs);
        vsPostLearn = beh2(ix2 & ixs);
        
        if ~keepTrials
            vsBase = grpstats(vsBase, B1.trial_index(ix1));
            vsPreLearn = grpstats(vsPreLearn, B2.trial_index(ix2 & ~ixs));
            vsPostLearn = grpstats(vsPostLearn, B2.trial_index(ix2 & ixs));
        end

        vs(ii,:) = [nanmean(vsBase) nanmean(vsPreLearn) nanmean(vsPostLearn)];
    end

    if doPlot
        hold on;
        plot.singleValByGrp(vs(:,1), grps, [], [], ...
            struct('LineMarkerStyle', 'r:', 'noColors', true));
        plot.singleValByGrp(vs(:,2), grps, [], [], ...
            struct('LineMarkerStyle', 'b:', 'noColors', true));
        plot.singleValByGrp(vs(:,3), grps, [], [], ...
            struct('LineMarkerStyle', 'b-', 'noColors', true));        
        ylabel(behNm);
        title(dtstr);
        legend({'B1', 'B2Pre', 'B2Post'});
    end

end
