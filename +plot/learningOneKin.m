function [Lmax, Lbest, Lraw] = learningOneKin(Y1, Y2)
% Y1 is learning in Blk1
% Y2 is learning in Blk2

    ys = [Y1; Y2];
    ysnrm = zscore(ys);

    b1 = ysnrm(1:numel(Y1));
    b2 = ysnrm(numel(Y1)+1:end);

    Lmax = mean(b1) - b2(1);
    Lraw = b2 - b2(1);
    Lbest = max(sign(Lmax)*Lraw)*sign(Lmax); % make same sign as Lmax

    [Lmax Lbest];

end
