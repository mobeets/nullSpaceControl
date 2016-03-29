function Z = condFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'thetaTol', 15, 'doSample', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    
    [nt, nn] = size(B2.latents);
    nNull = size(NB2,2);    
    
    % train
    YR = B1.latents*RB2;
    YN = B1.latents*NB2;
    
    % set col_order
%     col_order = 1:nNull;
%     col_order = getColOrder_LargestYRCorr(YN, YR)
    col_order = getColOrder_SortedCorr(YN, YR)
    % WARNING: both of these yield same exact solution somehow?
    
    Y = [YR YN(:,col_order)];
    mdls = cell(nNull,1);
    for ii = 1:nNull
        Xc = Y(:,1:2+ii-1); % use first 2+ii-1 cols
%         Xc = [Xc ones(size(Xc,1),1)];
        Yc = Y(:,ii+2); % to predict the next col
        mdls{ii} = fitlm(Xc, Yc);
    end
    
    % predict
    Zsamp = nan(nt,nNull);
    YR2 = B2.latents*RB2;
    for ii = 1:nNull
        Xc = [YR2 Zsamp(:,1:(ii-1))];
        Zsamp(:,ii) = predict(mdls{ii}, Xc);
    end
    
    % reorder
    Zsamp2 = nan(size(Zsamp));
    for ii = 1:numel(col_order)
        Zsamp2(:,col_order(ii)) = Zsamp(:,ii);
        disp(['col ' num2str(ii) ' to ' num2str(col_order(ii))]);
    end
    Zsamp = Zsamp2;

    % warning: reorder by col_order
    Zn = Zsamp*NB2';
    Zr = B2.latents*(RB2*RB2');
    Z = Zr + Zn;
end

function col_order = getColOrder_LargestYRCorr(YN, YR)

    nNull = size(YN,2);
    r = nan(nNull,1);
    for ii = 1:nNull
        [~,~,r(ii),~,~] = canoncorr(YR, YN(:,ii));
    end
    [~, col_order] = sort(-r); % largest corrs first
    
end

function col_order = getColOrder_SortedCorr(YN, YR, inds, col_order)
% take the next column depending on what has the max correlation with the
% previous columns
% 
    nNull = size(YN,2);
    if nargin < 3
        inds = 1:nNull;
    end
    if nargin < 4
        col_order = [];
    end
    if nNull == 1
        assert(numel(inds)==1);
        col_order = [col_order inds(1)];
        return;
    end
    r = nan(nNull,1);
    for ii = 1:nNull
        [~,~,r(ii),~,~] = canoncorr(YR, YN(:,ii));
    end
    [~, cur_col_order] = sort(-r); % largest corrs first
    keep = cur_col_order(1);
    
    trueKeepInd = inds(keep);
    col_order = [col_order trueKeepInd];
    inds = inds(inds ~= trueKeepInd);
    
    YR = [YR YN(:,keep)];
    YN(:,keep) = nan;
    YN = YN(:,~all(isnan(YN)));
    col_order = getColOrder_SortedCorr(YN, YR, inds, col_order);
    
end

% function condPred(B1Y, B2y, ind)
% % B1Y is all Blk1 responses, where first 2 cols are in row space of Blk2
% % B2y is given Blk2 response, with nans where unknown
% % ind is column to predict (one of the nans)
% 
%     ix = ~isnan(B2y);
%     X = B1Y(ix,:); % X training set
%     Y = B1Y(ind,:); % Y training set
%     x = B2y(ix); % x test point
% 
% end
