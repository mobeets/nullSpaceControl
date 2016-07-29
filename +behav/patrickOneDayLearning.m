function [Lrn, PrfHit] = patrickOneDayLearning(ys, zs, muy, sdy, muz, sdz)
    Pba = [(ys{1}-muy)./sdy (zs{1}-muz)./sdz];
    Pp = [(ys{2}-muy)./sdy (zs{2}-muz)./sdz];
    Lmx = nanmean(Pba) - Pp(1,:);
    Lmxnrm = Lmx./norm(Lmx);
    Lrw = bsxfun(@plus, Pp, -Pp(1,:));
    Lproj = (Lrw*Lmxnrm')*Lmxnrm;
    Lbin = sqrt(sum(Lproj.^2,2))/norm(Lmx);
    
    Lrn = nanmax(Lbin);
    PrfHit = norm(Lmx);
end
