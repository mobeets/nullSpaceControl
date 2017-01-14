
doSave = false;
saveDir = 'plots';
popts = struct('width', 4, 'height', 6, 'margin', 0.125);

%% trial_length

dtstr = '20131205';

% behavNm = 'trial_length';
behavNm = 'isCorrect';

if strcmpi(behavNm, 'isCorrect')
    ps = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
    D = io.quickLoadByDate(dtstr, ps);
else
    D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan));
end

%%

binSz = 50;
clr = 'k';
lw = 3;
FontSize = 22;

close all;
plot.init(FontSize);
for ii = 1:2
    B = D.blocks(ii);
    xs = B.trial_index;
    ys = B.(behavNm);
    if strcmpi(behavNm, 'isCorrect')
        ymn = 50;
        ys = 100*ys;
    else
        ymn = 0;
    end

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
        yl = ylim;
        yl(1) = ymn;
        yl(2) = 1.05*yl(2);
        plot([xmn xmn], yl, 'k--', 'LineWidth', 2);
    end
end

xlabel('Trial #');
if strcmp(behavNm, 'trial_length')
    ylabel('Target acquisition time (sec)');
    ylim([ymn yl(2)]);
elseif strcmp(behavNm, 'isCorrect')
    ylabel('Percent correct');
    yl = ylim;
    ylim([ymn 100]);
end
set(gca, 'Ticklength', [0 0]);
set(gca, 'LineWidth', lw);

figs.setPrintSize(gcf, opts);
export_fig(gcf, fullfile('plots', ['lrnByTrial_' behavNm '.pdf']));
