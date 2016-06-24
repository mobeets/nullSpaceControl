

%%

fitNm = 'nIme_yBnds';
lopts = struct('postLoadFcn', nan);
hypopts = struct('nBoots', 0,  'obeyBounds', true,'scoreGrpNm', 'thetaActualGrps16');
popts = struct();
pms = struct('MAX_ANGULAR_ERROR', 30);

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    S{ii,2} = D.score;
    close all;
end

fitNm = 'yIme_yBnds';
lopts = struct('postLoadFcn', @io.makeImeDefault);
hypopts = struct('nBoots', 0,  'obeyBounds', true, 'scoreGrpNm', 'thetaActualGrps16');
popts = struct();
pms = struct('MAX_ANGULAR_ERROR', 30);

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = fitByDate(dtstr, pms, nms, popts, lopts, hypopts);
    S{ii,4} = D.score;
    close all;
end

%%

close all;
[ndts, nrnds] = size(S);
clrs = [0.8 0.2 0.2; 0.8 0.6 0.6; 0.2 0.2 0.8; 0.6 0.6 0.8];
nhyps = numel(S{1});
plot.init;
for ii = 1:ndts
%     plot.init;
    subplot(2,3,ii); hold on;
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
