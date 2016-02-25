%% make sure colors align

% toggle "D = tools.rotateLatentsUpdateDecoders(D, true);"
D = io.quickLoadByDate(2);
B1 = D.blocks(1);
close all;
figure; set(gcf, 'color', 'w'); axis off;
hold on;
trgs = unique(B1.target, 'rows');
clrs = cbrewer('qual', 'Set2', size(trgs,1));
for ii = 1:size(trgs,1)
    v = trgs(ii,:);
    v(2) = v(2) - mean(trgs(:,2));
    v = v./norm(v);
    plot(v(1), v(2), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
    ix = B1.target(:,1) == trgs(ii,1) & B1.target(:,2) == trgs(ii,2);
    y = mean(B1.latents(ix,:)*B1.fDecoder.RowM2);
    y = y./norm(y);
    plot(y(1), y(2), 'ks', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
end

%%

dts = io.getDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    fitByDate(dtstr, true, true);
end
