function meanActivityTowardsTarget(D)

    figure; set(gcf, 'color', 'w');
    subplot(1,2,1);
    axis off; hold on;
    plotBlock(D.blocks(1));
    title('Intuitive');
    subplot(1,2,2);
    axis off; hold on;
    plotBlock(D.blocks(2));
    title('Shuffle');

end

function plotBlock(B)
    RB = B.fDecoder.M2';
    trgs = unique(B.target, 'rows');
    grps = sort(unique(B.thetaGrps));
    clrs = cbrewer('qual', 'Set2', size(trgs,1));
    for ii = 1:size(trgs,1)
        v = trgs(ii,:);
        v(1) = v(1) - mean(trgs(:,1));
        v(2) = v(2) - mean(trgs(:,2));
        v = v./norm(v);
        plot(v(1), v(2), 'ko', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
        ix = B.target(:,1) == trgs(ii,1) & B.target(:,2) == trgs(ii,2);
        grp = mode(B.thetaGrps(ix));
        ix = B.thetaGrps == grp;
        y = mean(B.latents(ix,:)*RB);
        y = y./norm(y);
        plot(y(1), y(2), 'ks', 'MarkerFaceColor', clrs(ii,:), 'MarkerSize', 20);
    end
    axis equal;
end
