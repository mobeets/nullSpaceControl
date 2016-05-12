function Z = fitByTargGrps(D, fitFcn, opts, grpNm, blkToFit, kind)
    if nargin < 3
        opts = struct();
    end
    if nargin < 4
        grpNm = 'thetaGrps';
    end
    if nargin < 5
        blkToFit = 2;
    end
    if nargin < 6
        kind = 1;
    end
    grps = score.thetaCenters(8);    
    blkPred = @(ths) (@(B) ismember(B.(grpNm), ths));
    
    if kind == 1
        grps = reshape(grps, size(grps,1)/2, []);
        rnds = [3 1; 4 2; 1 3; 2 4];
        rndB1 = circshift((1:4)', 2); rndB2 = (1:4)';
    else
        rndB1 = repmat(1:8, 8, 1);
        rndB1(logical(eye(size(rndB1)))) = nan;
        rndB2 = (1:8)';
    end
    
    Z = nan(size(D.blocks(blkToFit).latents));
    for ii = 1:size(rndB1,1)
        grp1 = rndB1(ii,:); grp1 = grp1(~isnan(grp1));
        grp2 = rndB2(ii,:); grp2 = grp2(~isnan(grp2));
        blk1Pred = blkPred(grps(grp1,:));
        blk2Pred = blkPred(grps(grp2,:));
        [Dc, ~, ix2] = io.initTargBlocks(D, blkToFit, blk1Pred, blk2Pred);
        Z(ix2,:) = fitFcn(Dc, opts);
    end
    
end
