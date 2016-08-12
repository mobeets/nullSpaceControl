
nunits = 20;
nsamps = 50;
rates = abs(round(normrnd(20, 10, [nunits 1])));

plot.init;
axis off;
for ii = 1:nunits
    sps = rand(poissrnd(rates(ii)), 1);
    for jj = 1:numel(sps)
        plot([sps(jj) sps(jj)], [ii-0.45 ii+0.45], 'k-', 'LineWidth', 2);
    end
end
