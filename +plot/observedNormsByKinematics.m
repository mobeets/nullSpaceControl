function observedNormsByKinematics(D, fldr)
    
    doNull = {0, 1, 'row'};
    doNullClr = cbrewer('qual', 'Set2', 3);
    doNullNm = {'full', 'null', 'row'};
    for nbind = 1:2
        for bind = 1:2
            if nbind == 1 && bind == 2
                continue;
            end
            fig = figure;
            for jj = 1:3
                ths = D.blocks(bind).thetas + 180;
                Y1 = D.blocks(bind).latents;

                nm = ['Blk' num2str(bind) ' in Blk' num2str(nbind)];
                [ys, xs] = plot.valsByKinematics(D, ths, Y1, ...
                    [], 8, doNull{jj}, nbind);
                plot.byKinematics(xs, ys, nm, doNullClr(jj,:));

            end
            legend(doNullNm);
            figNm = [D.datestr ' - ' nm];
            title(figNm);
            if ~isempty(fldr)
                saveas(fig, fullfile(fldr, figNm), 'png');
            end
        end
    end

end
