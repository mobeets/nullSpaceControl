
doSave = true;
saveDir = fopts.plotdir;
popts = struct('width', 4, 'height', 6, 'margin', 0.125);

%% trial_length

dtstr = '20131205';

% D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan));
% ps = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
% D = io.quickLoadByDate(dtstr, ps);

% behavNm = 'trial_length';
behavNm = 'isCorrect';
binSz = 50;
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
if strcmp(behavNm, 'trial_length')
    ylabel('Target acquisition time (sec)');
elseif strcmp(behavNm, 'isCorrect')
    ylabel('Proportion correct');
    yl = ylim;
    ylim([yl(1) 1]);
end
set(gca, 'Ticklength', [0 0]);

figs.setPrintSize(gcf, opts);
if doSave
    export_fig(gcf, fullfile(saveDir, ['lrnByTrial_' behavNm '.pdf']));
end
