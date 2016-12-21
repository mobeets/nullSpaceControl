
doSave = true;
saveDir = fopts.plotdir;
wd = 5; ht = 5; mrg = 0.125;

% dtstr = '20120528';
% D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan));
binSz = 50;
behavNm = 'trial_length';
clr = 'k';
lw = 3;

plot.init;
for ii = 1:2
    B = D.blocks(ii);
    xs = B.trial_index;
    ys = B.(behavNm);

    % avg by trial and smooth
    xsb = unique(xs);
    ysb = grpstats(ys, xs);
    ysb = smooth(xsb, ysb, binSz);
    
    if strcmp(behavNm, 'trial_length')
        ysb = (ysb*45)/1000; % convert to seconds
    end

    inds = 2:(numel(ysb)-1); % keep it from looking jumpy    
    plot(xsb(inds), ysb(inds), '-', 'LineWidth', lw, 'Color', clr);
    
    if ii == 2
        xmn = min(xsb);
        yl = ylim; yl(2) = 1.05*yl(2);
        plot([xmn xmn], yl, 'k--');
    end
end

xlabel('Trial #');
ylabel('Target acquisition time (sec)');
% yl = ylim; ylim([0 max(yl)]);
set(gca, 'TickDir', 'out');
set(gca, 'Ticklength', [0 0]);

figs.setPrintSize(gcf, wd, ht, mrg);
if doSave
    export_fig(gcf, fullfile(saveDir, 'lrnByTrial.pdf'));
end
