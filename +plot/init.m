function fig = init(FontSize)
    if nargin < 2
        FontSize = 18;
    end
    fig = figure;
    set(gcf, 'color', 'w');
    set(gcf, 'PaperPositionMode', 'auto'); % save the fig how it looks on screen
    hold on;
    set(gca, 'FontSize', FontSize);    
end
