function fig = plotErrByBlock(b1, b2)

    b1c = b1.cErrs;
    b2c = b2.cErrs;
    b1m = b1.mdlErrs;
    b2m = b2.mdlErrs;
    
    % get trial indices
    is1 = b1.by_trial.trial_inds;
    is2 = b2.by_trial.trial_inds;
    ts1 = b1.trial_inds;
    ts2 = b2.trial_inds;
    xs1 = ts1(is1);
    xs2 = ts2(is2);

    clr1 = [0.8 0.2 0.2];
    clr2 = [0.2 0.2 0.8];
    nt1 = numel(b1c);
    nt2 = numel(b2c);
    lw = 2;
    k1 = round(nt1*0.1);
    k2 = round(nt2*0.1);

    fig = plot.init;

    plot(xs1, smooth(abs(b1c), k1), 'Color', clr1, 'LineWidth', lw);
    plot(xs1, smooth(abs(b1m), k1), '--', 'Color', clr1, 'LineWidth', lw);

    plot(xs2, smooth(abs(b2c), k2), 'Color', clr1, 'LineWidth', lw);
    plot(xs2, smooth(abs(b2m), k2), '--', 'Color', clr1, 'LineWidth', lw);
    
    plot([max(xs1)+1 max(xs1)+1], ylim, 'k--');
    xlabel('trial #');
    ylabel('absolute angular error (degrees)');
end
