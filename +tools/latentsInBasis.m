function [Yc, YNc, YRc] = latentsInBasis(Y, NB, RB)
    YNc = Y*NB;
    YRc = Y*RB;
    Yc = [YNc YRc];
end
