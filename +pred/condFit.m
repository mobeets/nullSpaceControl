function Z = condFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'useThetas', false);
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
    YR2 = B2.latents*RB2;
    
    if opts.useThetas
%         YR = [YR cosd(B1.thetas) sind(B1.thetas)];
%         YR2 = [YR2 cosd(B2.thetas) sind(B2.thetas)];
        YR = [YR cosd(B1.thetaGrps) sind(B1.thetaGrps)];
        YR2 = [YR2 cosd(B2.thetaGrps) sind(B2.thetaGrps)];
    end
    
    % set col_order
    col_order = 1:nNull;
%     col_order = getColOrder_LargestYRCorr(YN, YR)'
%     col_order = getColOrder_SortedCorr(YN, YR)
    % WARNING: both of these yield same exact solution somehow?
    
    % TO DO: add in thetas to regression
    mdls = fitModels(YR, YN, col_order);
    
    % predict
    Zsamp = nan(nt,nNull);
    for ii = 1:nNull
        Xc = [YR2 Zsamp(:,1:(ii-1))];
        Zsamp(:,ii) = predict(mdls{ii}, Xc);
    end
    
    % reorder
    Zsamp2 = nan(size(Zsamp));
    for ii = 1:numel(col_order)
        Zsamp2(:,col_order(ii)) = Zsamp(:,ii);
    end
    Zsamp = Zsamp2;

    Zn = Zsamp*NB2';
    Zr = B2.latents*(RB2*RB2');
    Z = Zr + Zn;
end

function mdls = fitModels(YR, YN, col_order)
    Y = [YR YN(:,col_order)];
    nNull = numel(col_order);
    nRow = size(YR,2);
    mdls = cell(nNull,1);
    for ii = 1:nNull
        Xc = Y(:,1:nRow+ii-1); % use first 2+ii-1 cols
        Yc = Y(:,nRow+ii); % to predict the next col
        mdls{ii} = fitlm(Xc, Yc);%, 'quadratic');
    end
    arrayfun(@(ii) mdls{ii}.Rsquared.Ordinary, 1:numel(mdls))
end

function col_order = getColOrder_LargestYRCorr(YN, YR)

    nNull = size(YN,2);
    r = nan(nNull,1);
    for ii = 1:nNull
        mdl = fitlm(YR, YN(:,ii));
        r(ii) = mdl.Rsquared.Ordinary;
%         [~,~,r(ii),~,~] = canoncorr(YR, YN(:,ii));
    end
    [~, col_order] = sort(-r); % largest corrs first
%     r(col_order)'
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
        mdl = fitlm(YR, YN(:,ii));
        r(ii) = mdl.Rsquared.Ordinary;
%         [~,~,r(ii),~,~] = canoncorr(YR, YN(:,ii));
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
