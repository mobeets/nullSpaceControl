
lopts = struct('postLoadFcn', @io.makeImeDefault);

plot.init;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.quickLoadByDate(dtstr, [], lopts);
    Y = D.blocks(2).latents;
    NB = D.blocks(2).fImeDecoder.NulM2;
    YN = Y*NB;
    [u,s,v] = svd(YN);
    S{ii} = s;
    subplot(2,3,ii); hold on;
    plot(diag(s), 'ko-', 'LineWidth', 4);
%     bar(diag(s), 'FaceColor', 'w');
    set(gca, 'XTick', 1:size(v,1));
    title(dtstr);
end

%%

Y = D.hyps(1).latents;
NB = D.blocks(2).fImeDecoder.NulM2;
YN = Y*NB;
[u,s,v] = svd(YN);

close all;
Zs = cell(numel(D.hyps),1);
nms = cell(size(Zs));
for ii = 1:numel(D.hyps)
    Yh = D.hyps(ii).latents*NB*v;
    Zs{ii} = Yh(:,1:2);
    nms{ii} = D.hyps(ii).name;
end

%%

[P1, Ps, xs, ys, b1, bs, scs] = compareKde(Zs{1}, Zs(2:end), true);

plot.init;
for ii = 1:numel(Zs)
    if ii == 1
        Pc = P1;
    else
        Pc = Ps{ii-1};
    end
    subplot(3,3,ii);
    plotKde(xs, ys, Pc, Zs{ii});
    title(nms{ii});
end

%%

plot.init;
plot.barByHyp(scs, nms(2:end));

plot.init;
plot.barByHyp([D.score(2:end).errOfMeans], nms(2:end));
