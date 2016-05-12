function plotErrByBlock(b1, b2)

    b1c = cell2mat(b1.cErrs);
    b2c = cell2mat(b2.cErrs);
    b1m = cell2mat(b1.mdlErrs);
    b2m = cell2mat(b2.mdlErrs);

    clr1 = [0.8 0.2 0.2];
    clr2 = [0.2 0.2 0.8];
    nt1 = numel(b1c);
    nt2 = numel(b2c);
    lw = 2;
    k1 = round(nt1*0.1);
    k2 = round(nt2*0.1);
    
    plot.init;
    
    xs1 = 1:nt1;    
    plot(xs1, smooth(abs(b1c), k1), 'Color', clr1, 'LineWidth', lw);
    plot(xs1, smooth(abs(b1m), k1), 'Color', clr2, 'LineWidth', lw);
        
    xs2 = (nt1+1):(nt1+nt2);
    plot(xs2, smooth(abs(b2c), k2), 'Color', clr1, 'LineWidth', lw);
    plot(xs2, smooth(abs(b2m), k2), 'Color', clr2, 'LineWidth', lw);
    plot([nt1 nt1], ylim, 'k--');
    
    xlabel('trial #');
    ylabel('absolute angular error (degrees)');
end
    