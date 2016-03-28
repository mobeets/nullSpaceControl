function popts = hypothesisErrorByTime(D, binNm, tbins, ...
    binSz, doKins, popts, hypopts, extraNm)
    
    [errMus, ns, allErrMus, errMusKins, allErrMusKins, nsKins] = ...
        plot.hypothesisErrorByField(D, binNm, tbins, binSz, extraNm, hypopts);
    nhyps = numel(D.hyps)-1;
    clrs = cbrewer('qual', 'Set2', nhyps);
%     clrs = cbrewer('div', 'RdYlGn', nhyps);
    if doKins
        errs = errMusKins;
        allErrs = allErrMusKins';
        nsAll = nsKins;
    else
        errs = {errMus};
        allErrs = allErrMus;
        nsAll = {ns};
    end
    grps = score.thetaCenters(8);
    
    for kk = 1:numel(errs)
        errCur = errs{kk};
        ns = nsAll{kk};
        allErrCur = allErrs(kk,:);
        if doKins
            suff = ['th=' num2str(grps(kk))];
        else
            suff = '';
        end
        figure; set(gcf, 'color', 'w');
        hold on; set(gca, 'FontSize', 14);
        
        for ii = 1:nhyps
            if ~strcmpi(D.hyps(ii+1).name, 'kinematics mean')
                plot(tbins, errCur(:,ii), 'Color', clrs(ii,:), 'LineWidth', 3);
            else % assumes this is kinematics-mean
                plot([min(tbins) max(tbins)], [allErrCur(ii) allErrCur(ii)], ...
                    '-', 'Color', clrs(ii,:), 'LineWidth', 3);%, 'HandleVisibility', 'off');
            end
        end

        plot(tbins, ns/max(ns), '--', 'Color', [0.5 0.5 0.5]);
        xlabel(binNm);
        ylabel('errMus');
        legend([{D.hyps(2:end).name} extraNm], 'Location', 'BestOutside');
        title([D.datestr ' ' suff]);
                
        fnm = fullfile(popts.plotdir, [D.datestr '_' suff '.png']);
        [popts.doSave, popts.askedOnce] = plot.checkSafeToSave(...
            popts.plotdir, fnm, popts.doSave, popts.askedOnce);
        if popts.doSave
            saveas(gcf, fnm, 'png');
        end
    end
    
end
