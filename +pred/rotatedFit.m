function [Z, R] = rotatedFit(D, H)

    Blk = D.blocks(2);
    ix0 = Blk.idxTrain;
    ix1 = Blk.idxTest;
    NB = Blk.fDecoder.NulM2;
    
    Y0train = Blk.latents(ix0,:)*NB;
    Y1train = H.latents(ix0,:)*NB;
    
    % roughly, find the rotation R so that corr(Y1*R, Y0) is maximum
    [~, R, Yfcn] = pred.rotatePrediction(Y0train, Y1train);
    
    Y1test = H.latents(ix1,:)*NB;
    Y1h = Yfcn(Y1test);
    Z = nan(size(H.latents));
    Z(ix1,:) = Y1h*NB'; % projects out of null space
end
