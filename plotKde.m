function plotKde(X, Y, P, Z)
    surf(X, Y, P, 'LineStyle', 'none');
%     view([0,60]);
    view(2);
    colormap hot;
    hold on;
    alpha(.8);
    set(gca, 'color', 'blue');
    plot(Z(:,1), Z(:,2), 'w.', 'MarkerSize', 5);
    
    xrng = [min(X(:)) max(X(:))]; yrng = [min(Y(:)) max(Y(:))];
    xlim(xrng);
    ylim(yrng);
end
