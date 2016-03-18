function showTrial(B, tis, flds)
% tis: list of trial indices of trials to show

    if nargin < 3
        flds = {};
    end
    
    clr = [0.2 0.2 0.8];
    xl = tools.getLims(B.target(:,1), 0.2);
    yl = tools.getLims(B.target(:,2), 0.2);
%     mn = min(B.target); mx = max(B.target);
%     xl = [mn(1) mx(1)];
%     yl = [mn(2) mx(2)];
%     xl = tools.addMarginToLimits(xl, 0.2);
%     yl = tools.addMarginToLimits(yl, 0.2);
    
    if isfield(B, 'target')
        st = median(B.target);
    else
        st = median(B.targetLocations(:,1:2));
    end
    
    for ii = 1:numel(tis)
        ti = tis(ii);

        if isfield(B, 'trial_index')
            ix = B.trial_index == ti;
            if sum(ix) == 0
                continue;
            end
            ps = B.pos(ix,:);
            targ = nanmean(B.target(ix,:));
            if ~isempty(flds)
                fld = B.(flds{1});
            else
                fld = [];
            end
        else
            ps = B.decodedPositions{ti};
            targ = B.targetLocations(ti,1:2);
            if ~isempty(flds)
                fld = B.(flds{1});
                fld = fld(ti);
            else
                fld = [];
            end
        end
        nt = size(ps,1);
        disp(ti);
        clf;
        set(gcf, 'color', 'w');
        hold on;
        set(gca, 'FontSize', 14);                        
        plot(st(1), st(2), 'r+');
        xlim(xl); ylim(yl);
        pause(1.0);

        for t = 1:nt
            clf;
            set(gcf, 'color', 'w');
            hold on;
            set(gca, 'FontSize', 14);                        
            plot(st(1), st(2), 'r+');
            plot(targ(1), targ(2), '+', 'Color', clr);
            plot(targ(1), targ(2), 'o', 'Color', clr);
            plot(ps(t,1), ps(t,2), 'o', 'Color', clr, 'MarkerFaceColor', clr);
            xlim(xl); ylim(yl);
            if ~isempty(fld)
                if size(fld,1) == nt
                    fd = fld(t);
                else
                    fd = fld;
                end
                text(xl(1)/2, st(2), num2str(fd));
            end
            pause(0.1);
        end
    end
    clf;
    set(gcf, 'color', 'w');
    hold on;
    set(gca, 'FontSize', 14);                        
    plot(st(1), st(2), 'r+');
    xlim(xl); ylim(yl);

end
