function performanceVsError(D, H)

    B = D.blocks(2);
    ths = B.thetas + 180;
    Y1 = B.latents;
    Y2 = H.latents;
    [ys, xs] = plot.valsByKinematics(D, ths, Y1, Y2, 8, true, 2);
%     plot.byKinematics(xs, ys, H.name, [0.2 0.2 0.8]);

    % these are really per target goal and not per kinematics, but whatever
    df = D.simpleData.shufflePerformance.target;    

    xs0 = df.angle;
    assert(isequal(xs0, xs));
    df1 = df.initialDifficulty;
    allPlots(df1, xs, ys);
    df2 = df.lateDifficulty;
    allPlots(df2, xs, ys);
    allPlots(df2, xs, ys, df1);


end

function allPlots(df, xs, ys, df0)
    fns = fieldnames(df);
    clrs = cbrewer('qual', 'Set2', numel(fns));
    for ii = 1:numel(fns)
        vs = df.(fns{ii});
        if nargin > 3
            vs = vs - df0.(fns{ii});
        end
%         plot(xs, vs./max(vs), 'LineWidth', 3);
        figure; hold on; set(gcf, 'color', 'w'); box off;
        set(gca, 'FontSize', 14);
        xlabel('error');
        ylabel(fns{ii});
        plot(ys, vs./max(vs), 'o', ...
            'Color', clrs(ii,:), 'MarkerFaceColor', clrs(ii,:));
    end
end
