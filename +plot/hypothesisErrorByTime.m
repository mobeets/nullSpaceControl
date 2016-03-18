function [doSave, askedOnce] = hypothesisErrorByTime(D, binNm, tbins, ...
    binSz, doKins, fldr, doSave, askedOnce)

    [errMus, ns, allErrMus, errMusKins, allErrMusKins] = ...
        plot.hypothesisErrorByField(D, binNm, tbins, binSz);
    nhyps = numel(D.hyps)-1;
    clrs = cbrewer('qual', 'Set2', nhyps);
%     clrs = cbrewer('div', 'RdYlGn', nhyps);
    if doKins
        errs = errMusKins;
        allErrs = allErrMusKins';
    else
        errs = {errMus};
        allErrs = allErrMus;
    end
    grps = score.thetaCenters(8);
    
    for kk = 1:numel(errs)
        errCur = errs{kk};
        allErrCur = allErrs(kk,:);
        if doKins
            suff = ['th=' num2str(grps(kk))];
        else
            suff = '';
        end
        figure; set(gcf, 'color', 'w');
        hold on; set(gca, 'FontSize', 14);
        
        for ii = 1:nhyps
            if ii > 1
                plot(tbins, errCur(:,ii), 'Color', clrs(ii,:), 'LineWidth', 3);
            end
            if ii == 1
                plot([min(tbins) max(tbins)], [allErrCur(ii) allErrCur(ii)], ...
                    '-', 'Color', clrs(ii,:), 'LineWidth', 3);%, 'HandleVisibility', 'off');
            end
        end

        plot(tbins, ns/max(ns), '--', 'Color', [0.5 0.5 0.5]);
        xlabel(binNm);
        ylabel('errMus');
        legend({D.hyps(2:end).name});%, 'Location', 'BestOutside');
        title([D.datestr ' ' suff]);
                
        fnm = fullfile(fldr, [D.datestr '_' suff '.png']);
        [doSave, askedOnce] = plot.checkSafeToSave(fldr, fnm, doSave, askedOnce);
        if doSave
            saveas(gcf, fnm, 'png');
        end
    end
    
end
