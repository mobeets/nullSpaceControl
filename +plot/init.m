function init(FontSize)
    if nargin < 2
        FontSize = 18;
    end
    figure;
    set(gcf, 'color', 'w');
    hold on;
    set(gca, 'FontSize', FontSize);
end

