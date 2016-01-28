function tmp(D, Hs, fldr, nms)

    for ii = 1:numel(Hs)
        H = Hs(ii);
        fig = figure;
        plot.errorByKinematics(D, H, H.name, 8);
        if ~isempty(fldr)
            saveas(fig, fullfile(fldr, [D.datestr ' - ' nms{ii}]), 'png');
        end
    end

end
