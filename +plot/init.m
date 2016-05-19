function fig = init(FontSize)
    if nargin < 2
        FontSize = 18;
    end
    fig = figure;
    set(gcf, 'color', 'w');
    hold on;
    set(gca, 'FontSize', FontSize);
end

