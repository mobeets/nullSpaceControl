function [Hs, H0] = fitGrpsOneBlock(D, nms, hypopts, grpNm, blkToFit)
    if nargin < 3
        hypopts = struct();
    end
    if nargin < 4
        grpNm = 'thetaGrps';
    end
    if nargin < 5
        blkToFit = 2;
    end
    if isfield(D, 'hyps')
        error('Sorry, you have to remove hyps from D.');
    end
    
    grps = score.thetaCenters(8);
    grps = reshape(grps, size(grps,1)/2, []);
    blkPred = @(ths) (@(B) ismember(B.(grpNm), ths));
    
    D0 = D;
    D = pred.fitHyps(D, nms, hypopts);
    D = pred.nullActivity(D, hypopts);
    D = score.scoreAll(D);
    H0 = D.hyps;
    D = D0;
    
    Hs = cell(4,1);
    D = fitOne(D0, blkToFit, blkPred, grps(3,:), grps(1,:), nms, hypopts);
    Hs{1} = D.hyps;
    D = fitOne(D0, blkToFit, blkPred, grps(4,:), grps(2,:), nms, hypopts);
    Hs{2} = D.hyps;
    D = fitOne(D0, blkToFit, blkPred, grps(1,:), grps(3,:), nms, hypopts);
    Hs{3} = D.hyps;
    D = fitOne(D0, blkToFit, blkPred, grps(2,:), grps(4,:), nms, hypopts);
    Hs{4} = D.hyps;
    
    grps = score.thetaCenters(8);
    figure;
    plot.singleValByGrp(H0(end).errOfMeansByKin, grps);
    scs = cell2mat(cellfun(@(H) H(end).errOfMeansByKin, Hs, 'uni', 0));
    plot.singleValByGrp(scs(:), grps, [], [], ...
        struct('LineMarkerStyle', 'k--'));
end

function D = fitOne(D, blkToFit, blkPred, ths1, ths2, nms, hypopts)
    D = io.initTargBlocks(D, blkToFit, blkPred(ths1), blkPred(ths2));
    D = pred.fitHyps(D, nms, hypopts);
    D = pred.nullActivity(D, hypopts);
    D = score.scoreAll(D);
end
