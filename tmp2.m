function D = tmp2(D)

    NB1 = D.blocks(1).fDecoder.NulM2;
    RB1 = D.blocks(1).fDecoder.RowM2;
    NB2 = D.blocks(2).fDecoder.NulM2;
    RB2 = D.blocks(2).fDecoder.RowM2;
	
    colnrm = @(Y) sqrt(sum(Y.^2,2));
    
    Y1 = D.blocks(1).latents;
%     YN1 = Y1*(NB1*NB1');
%     YN1 = YN1*(NB2*NB2');
%     Y1 = Y1*(RB1*RB1') + YN1;
%     D.blocks(1).latents = Y1;
    
    Y2 = D.blocks(2).latents;
    YN = Y2*(NB1*NB1');
    YN = YN*(NB2*NB2');
    YR = Y2*(RB2*RB2');
    Y2 = YN + YR;
    D.blocks(2).latents = Y2;

end
