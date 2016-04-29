function z1 = rowSpaceFit(Blk, decoder, NB, RB, t)
% finds unique z1 in row space of decoder to satisfy kinematics
% 
% each z1 is unique solution to
%   (1) A*x0 + B*z1 + c = x1
%   (2) NB'*z1 = 0
% 
    
    x0 = Blk.vel(t,:)';
    x1 = Blk.velNext(t,:)';

    A = decoder.M1;
    B = decoder.M2;
    c = decoder.M0;
    
    z1p = (B*RB)\(x1 - A*x0 - c); % unique soln to (1)
    z1 = RB*z1p; % subject to (2)
    
    assert(norm((x1 - A*x0 - c) - B*z1) < 1e-10); % satisfies (1)
    assert(norm(NB'*z1) < 1e-11); % satisfies (2)

end
