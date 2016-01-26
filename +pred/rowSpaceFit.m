function z1 = rowSpaceFit(Blk, decoder, NB, RB, t)
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
    
    Brow = RB; % tools.getNullBasis(NB'); % recover row space from null space (???)
    z1p = (B*Brow)\(x1 - A*x0 - c); % unique soln to (1)
    z1 = Brow*z1p; % subject to (2)
    
    assert(norm((x1 - A*x0 - c) - B*z1) < 1e-10); % satisfies (1)
    assert(norm(NB'*z1) < 1e-11); % satisfies (2)

end
