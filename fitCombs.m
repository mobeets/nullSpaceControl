
nms = {'unconstrained', 'habitual', 'pruning', 'cloud', 'cloud-og', ...
    'mean shift prune', 'mean shift'};
popts = struct('plotdir', '', 'doSave', true, 'doTimestampFolder', false);
ndts = numel(io.getAllowedDates());
S = cell(ndts, 4);

%%

fitNm = 'nIme_thetaActuals';
lopts = struct('postLoadFcn', nan);
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    popts.plotdir = ['plots/' fitNm '/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    S{ii,1} = D.score;
    close all;
end

%%

fitNm = 'nIme_thetas';
lopts = struct('postLoadFcn', nan);
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaGrps16');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    popts.plotdir = ['plots/' fitNm '/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    S{ii,2} = D.score;
    close all;
end

%%

fitNm = 'yIme_thetaActuals';
lopts = struct('postLoadFcn', @io.makeImeDefault);
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    popts.plotdir = ['plots/' fitNm '/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    S{ii,3} = D.score;
    close all;
end

%%

fitNm = 'yIme_thetas';
lopts = struct('postLoadFcn', @io.makeImeDefault);
hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaGrps16');

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    popts.plotdir = ['plots/' fitNm '/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);
    S{ii,4} = D.score;
    close all;
end

%%

S = load('plots/scores.mat'); S = S.S;
close all;
[ndts, nrnds] = size(S);
clrs = [0.8 0.2 0.2; 0.8 0.6 0.6; 0.2 0.2 0.8; 0.6 0.6 0.8];
nhyps = numel(S{1});
for ii = 1:ndts
    plot.init;
    s = S(ii,:);
    scs = nan(nhyps, nrnds);
    for jj = 2:nhyps
        scs(jj,:) = arrayfun(@(kk) s{kk}(jj).errOfMeans, 1:4);
    end
    for jj = 1:nrnds
        sc = scs(:,jj);
        sc = sc - min(sc);
        sc = sc./max(sc);
        scs(:,jj) = sc;
    end
%     dts{ii}
%     scs
    
    for jj = 1:nrnds
        plot(1:nhyps, scs(:,jj), 'Color', clrs(jj,:), 'LineWidth', 3);
    end
    ylabel('mean error, normalized');
    set(gca, 'XTick', 1:8);
    set(gca, 'XTickLabel', {D.score.name});
    set(gca, 'XTickLabelRotation', 45);
    title(dts{ii});
end
