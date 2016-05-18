function plotWhiskers(D, bind, trialNo, doLatents)
    if nargin < 4
        doLatents = false;
    end

    TAU = 3;
    T_START = TAU + 2;
    TARGET_RADIUS = 20 + 18;

    [U, Y, Xtarget] = imefit.prep(D.blocks(bind), doLatents);
    [E_P, ~] = velime_extract_prior_whiskers(U, Y, Xtarget, D.ime(bind));
    
    plot.init;
    fill_circle(Xtarget{trialNo}, TARGET_RADIUS, 'g');
    plot(Y{trialNo}(1,:), Y{trialNo}(2,:), 'k-o');
    T = size(Y{trialNo}, 2);
    for t = T_START:T
        plot(E_P{trialNo}(1:2:end,t), E_P{trialNo}(2:2:end,t), 'r.-');
    end
    axis image;

end
