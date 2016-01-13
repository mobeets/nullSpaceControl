function z1 = rowSpaceFit(Blk, decoder, NB, t)
% 
% each z1 is unique solution to
%   (1) A*x0 + B*z1 + c = x1
%   (2) NB'*z1 = 0
% 
    
    x1 = Blk.vel(t);
    x0 = Blk.velPrev(t);
    A = decoder.M1;
    B = decoder.M2;
    c = decoder.M0;
    
    z1 = nan;

end
