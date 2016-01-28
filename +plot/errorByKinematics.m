function errorByKinematics(D, H, nm, nbins)

    if nargin < 3
        nm = '';
    end
    if nargin < 4
        nbins = 8;
    end
    
    cnts = score.thetaCenters(nbins);
    B = D.blocks(2);
    NB = B.fDecoder.NulM2;
    if true % doRotate
        [~,~,v] = svd(B.latents*NB);
        NB = NB*v;
    end
    
    xs0 = D.blocks(1).thetas + 180;
    Y0 = D.blocks(1).latents;
    ix = ~isnan(sum(Y0,2)); xs0 = xs0(ix); Y0 = Y0(ix,:);
    M0 = score.avgByThetaGroup(xs0, Y0*NB, cnts);
    
    xs = B.thetas + 180;
    Y1 = B.latents; Y2 = H.latents;
    ix = ~isnan(sum(Y1,2)) & ~isnan(sum(Y2,2));
    xs = xs(ix); Y1 = Y1(ix,:); Y2 = Y2(ix,:);
    M1 = score.avgByThetaGroup(xs, Y1*NB, cnts);
    M2 = score.avgByThetaGroup(xs, Y2*NB, cnts);    
    errs = arrayfun(@(ii) norm(M1(ii,:) - M2(ii,:)), 1:size(M1,1));
    errs = arrayfun(@(ii) norm(M0(ii,:) - M2(ii,:)), 1:size(M1,1));
    
    cmap = cbrewer('div', 'RdYlGn', numel(cnts));
    cmap = circshift(cmap, floor(numel(cnts)/2));
    
    sz = 50;
    hold on;
    
    set(gca, 'LineWidth', 3);
    set(gca, 'FontSize', 14);
    plot(cnts, errs, 'Color', [0.7 0.7 0.7], 'LineWidth', 3);
    for ii = 1:numel(cnts)
        scatter(cnts(ii), errs(ii), sz, cmap(ii,:), ...
            'MarkerFaceColor', cmap(ii,:));
    end    
    xlim([-25 385]);
    ylim([0 1.2*nanmax(errs)]);
    set(gca, 'XTick', cnts(1:2:end));
    
    set(gcf, 'color', 'white');
    if ~isempty(nm)
        title(nm, 'FontSize', 14);
    end
    xlabel('\theta');
    ylabel(['norm(actual - ' nm ')']);
%     ylabel(nm);

end
