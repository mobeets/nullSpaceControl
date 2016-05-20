function [estParams, LL, stats] = fitBlock(Blk, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('PARALLEL', false, 'max_iters', 200, 'TAU', 3, ...
        'TARGET_RADIUS', 20+18, 'init_method', 'current_regression', ...
        'verbose', true, 'doLatents', false, 'doCv', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if opts.doCv
        [BlkTrain, BlkTest] = imefit.trialIndsSplit(Blk);
    else
        BlkTrain = Blk; BlkTest = Blk;
    end
    [U, Y, Xtarget] = imefit.prep(BlkTrain, opts.doLatents);
    basedir = pwd;
    cd('velime_codepack_v1.0/');
    [estParams,LL] = velime_fit(U, Y, Xtarget, opts.TAU,...
        'INIT_METHOD', opts.init_method,...
        'verbose', opts.verbose,...
        'max_iters', opts.max_iters);
    cd(basedir);
    stats = imefit.imeStats(BlkTest, estParams, opts);

%     D.ime(bind) = estParams;
%     figure; plot(LL); title([D.datestr ' block ' num2str(bind) ' ime LL']);    
%     [mdlErrs, cErrs] = imefit.imeErrs(U, Y, Xtarget, estParams, ...
%         TARGET_RADIUS, T_START);
%     imefit.plotImeVsCursor(D, bind, mdlErrs, cErrs);
%     D0 = io.quickLoadByDate(dtstr, io.setUnfilteredDefaults(), struct('doRotate', false));
%     D0.ime(bind) = estParams;
%     b = imefit.plotImeStats(D, bind, doLatents);
%     saveas(gcf, fullfile('plots', 'ime2', [dtstr '_' num2str(bind) '_lts.png']));
end
