function Xsamp = histSample(X, Ps, nsamps)

    D = cumsum(Ps)/sum(Ps);
    p = @(r) find(r < D, 1, 'first');
    Xsamp = X(arrayfun(p, rand(nsamps,1)));

end