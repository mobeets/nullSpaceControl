function [M1, M2] = latentsInAllBases(D, decNm, doRotate)
    if nargin < 2
        decNm = 'fDecoder';
    end
    if nargin < 3
        doRotate = false;
    end
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    Y1 = B1.latents;
    Y2 = B2.latents;
    
    NB1 = B1.(decNm).NulM2;
    RB1 = B1.(decNm).RowM2;
    NB2 = B2.(decNm).NulM2;
    RB2 = B2.(decNm).RowM2;
    
    if doRotate
        [~,~,v] = svd(Y1*NB1); NB1 = NB1*v;
        [~,~,v] = svd(Y2*NB2); NB2 = NB2*v;
    end
    
    [M1.Y1, M1.YN1, M1.YR1] = tools.latentsInBasis(Y1, NB1, RB1);    
    [M1.Y2, M1.YN2, M1.YR2] = tools.latentsInBasis(Y2, NB1, RB1);
    [M2.Y1, M2.YN1, M2.YR1] = tools.latentsInBasis(Y1, NB2, RB2);
    [M2.Y2, M2.YN2, M2.YR2] = tools.latentsInBasis(Y2, NB2, RB2);
    
%     ZNR = Y1*(RB1*RB1')*NB1;
%     ZNN = Y1*(NB1*NB1')*NB1;
end
