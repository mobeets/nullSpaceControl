function [Lrns, PrfHits] = patrickLearning(dts)

    [Ys, Zs] = behav.patrickAllVals(dts);
    
    % compute mu/sdev for each monkey
    mnkNms = cellfun(@(n) n(1), io.addMnkNmToDates(dts), 'uni', 0);
    nms = unique(mnkNms);
    nmnks = numel(nms);
    mus = nan(nmnks,2);
    sds = nan(nmnks,2);
    for ii = 1:nmnks
        ix = strcmp(mnkNms, nms{ii});
        yc = cell2mat({Ys{ix,:}}');
        zc = cell2mat({Zs{ix,:}}');
        mus(ii,1) = nanmean(yc);
        mus(ii,2) = nanmean(zc);
        sds(ii,1) = nanstd(yc);
        sds(ii,2) = nanstd(zc);
    end

    % compute learning and performance hit for each session
    Lrns = nan(numel(dts),1);
    PrfHits = nan(numel(dts),1);
    for ii = 1:numel(dts)
        mInd = find(strcmp(nms, mnkNms{ii}));
        muy = mus(mInd,1);
        muz = mus(mInd,2);
        sdy = sds(mInd,1);
        sdz = sds(mInd,2);
        [Lrns(ii), PrfHits(ii)] = behav.patrickOneDayLearning(...
            Ys(ii,:), Zs(ii,:), muy, sdy, muz, sdz);
    end
    
end
