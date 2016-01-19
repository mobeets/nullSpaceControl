function z1 = rowSpaceFit(Blk, decoder, NB, t)
% 
% each z1 is unique solution to
%   (1) A*x0 + B*z1 + c = x1
%   (2) NB'*z1 = 0
% 
    
    x1 = Blk.vel(t,:)';
    x0 = Blk.velPrev(t,:)';
    A = decoder.M1;
    B = decoder.M2;
    c = decoder.M0;
    
    Brow = rref(B)';
    z1p = (B*Brow)\(x1 - A*x0 - c);
    
    Brow2 = null(NB');
    z1 = Brow2*z1p;
    
    assert(norm(NB'*z1) < 1e-12);

end
