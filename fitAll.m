
% nms = {'habitual', 'pruning', 'cloud', 'unconstrained', 'mean shift prune'};
nms = {'unconstrained', 'habitual', 'pruning', 'cloud', 'cloud-og', ...
    'mean shift prune', 'mean shift'};
% nms = {'habitual', 'pruning'};

hypopts = struct('nBoots', 0, 'scoreGrpNm', 'thetaActualGrps16');
lopts = struct('postLoadFcn', @io.makeImeDefault);
% lopts = struct('postLoadFcn', nan);
popts = struct();
% popts = struct('plotdir', '', 'doSave', true, 'doTimestampFolder', false);

dts = io.getAllowedDates();
Ss = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
%     popts.plotdir = ['plots/allNewNoIme/' dtstr];
    D = fitByDate(dtstr, [], nms, popts, lopts, hypopts);    
%     Ss{ii} = D.score;
%     continue;
% 
%     E = D;
%     D.hyps(1).latents = D.hyps(3).latents; % fit devs from pruning
%     D = rmfield(rmfield(D, 'score'), 'scores');
%     D = score.scoreAll(D, hypopts);
%     
%     
%     Ss2{ii} = D.score;
%     
%     
%     
%     S1 = {D.score(2:4).errOfMeansByKin};
%     S2 = {E.score(2:4).errOfMeansByKin};
%     plot.init;
%     for jj = [1 3]
%         xs = S1{jj};
%         ys = S2{jj} - S2{2}; % deviation from pruning's scores
%         plot(xs, ys, 'o');
%     end
%     xlabel('difference from pruning');
%     ylabel('error predicting observed');
%     legend({'habitual', 'cloud'});% legend boxoff;
%     title(dtstr);
%     v = axis; lo = min(v(1:2:end)); up = max(v(2:2:end)); axis([lo up lo up]);
%     
%     continue;
%     
%     figure; plot.barByHypQuick(D.score(2:end), 'errOfMeans');
% %     figure; plot.barByHypQuick(D.score(2:end), 'histErr');
%     
%     gs = D.blocks(2).(hypopts.scoreGrpNm);
%     grps = sort(unique(gs));
%     scs = nan(numel(grps), numel(D.hyps)-1);
%     for jj = 1:numel(grps)
%         grps(jj)
%         ix = grps(jj) == gs;
%         Y = D.hyps(1).nullActivity.zNull(ix,:);
%         Yhs = cellfun(@(obj) obj.zNull(ix,:), ...
%             {D.hyps(2:end).nullActivity}, 'uni', 0);
%         scs(jj,:) = score.kdeError(Y, Yhs, 'all');
%     end
%     Scs{ii} = scs;
%     
%     plot.init;
%     for jj = 1:size(scs,2)
%         plot(grps, scs(:,jj), '-o', 'LineWidth', 3);
%     end
%     legend({D.hyps(2:end).name});
%     legend boxoff;
%     
%     plot.init; plot.barByHyp(mean(scs), {D.score(2:end).name});
%     
% %     scs2{ii} = score.kdeError(Y, Yhs);
% %     plot.init; plot.barByHyp(scs2{ii}, {D.score(3:end).name});
% %     ylabel('base kde'); title(dtstr);
%     
%     continue;

%     ps = 1;
%     Zs = cell(numel(ps),1); nmsc = cell(size(Zs));
%     for jj = 1:numel(ps)
%         custopts = struct('minDist', nan, 'thetaTol', nan, 'kNN', 1);
%         Zs{jj} = pred.sameCloudFit(D, custopts);
%         nmsc{jj} = ['cloud-' num2str(ps(jj))];
%     end
%     D = pred.addAndScoreHypothesis(D, Zs, nmsc);

    Y = D.hyps(1).latents;
    NB = D.blocks(2).fImeDecoder.NulM2;
    gs = D.blocks(2).targetAngle;
    grps = sort(unique(gs));
    ngrps = numel(grps);
    
    Scs = nan(8, numel(D.hyps)-1);
    for kk = 1:ngrps
        ix = gs == grps(kk);
        
        YN = Y(ix,:)*NB;
        [u,s,v] = svd(YN);

        Zs = cell(numel(D.hyps),1);
        nms = cell(size(Zs));
        for jj = 1:numel(D.hyps)
            Yh = D.hyps(jj).latents(ix,:)*NB*v;
            Zs{jj} = Yh(:,1:2);
            nms{jj} = D.hyps(jj).name;
        end

        [P1, Ps, xs, ys, b1, bs, scs] = compareKde(Zs{1}, Zs(2:end), true);
        Scs(kk,:) = scs;

        plot.init;
        for jj = 1:numel(Zs)
            if jj == 1
                Pc = P1;
            else
                Pc = Ps{jj-1};
            end
            subplot(3,3,jj);
            plotKde(xs, ys, Pc, Zs{jj});
            title(nms{jj});
        end
    end
    
    plot.init;
    for kk = 1:size(Scs,2)
        plot(Scs(:,kk), '-o', 'LineWidth', 3);
    end
    legend(nms(2:end)); legend boxoff;
    title(D.datestr);
    
%     [~, inds] = sort({D.hyps.name});
    inds = 2:numel(D.hyps);
    figure;
    subplot(2,2,1); plot.barByHypQuick(D.score(inds), 'errOfMeans');
    subplot(2,2,2); plot.barByHypQuick(D.score(inds), 'kdeErr');
    subplot(2,2,3); plot.barByHyp(mean(Scs), nms(2:end));
%     subplot(2,1,2); plot.barByHypQuick(D.score(inds), 'covError');
%     subplot(2,2,3); plot.barByHypQuick(E.score(inds1), 'errOfMeans');
%     subplot(2,2,4); plot.barByHypQuick(E.score(inds1), 'covError');
%     title(D.datestr);
%     figure;
%     subplot(2,2,1); plot.errorByKin(D.score(inds), 'errOfMeansByKin');
%     subplot(2,2,2); plot.errorByKin(D.score(inds), 'covErrorByKin');
%     subplot(2,2,3); plot.errorByKin(E.score(inds1), 'errOfMeansByKin');
%     subplot(2,2,4); plot.errorByKin(E.score(inds1), 'covErrorByKin');
    title(D.datestr);
    
    
    
end

%%

% vs = {es11, es12, es22, es21};
% barNms = {'th', 'th, fit=thAct', 'thAct', 'thAct, fit=th'};
vs = {esBase, esIme};
barNms = {'base', 'ime'};

plot.init;
c = 0;
for jj = 2:4%numel(es11{1})
    c = c + 1;
    vals = cell(numel(vs),1);    
    subplot(1, 4, c); hold on;
    for jj = 1:numel(vs)
%         vals{jj} = cellfun(@(x) x(ii), vs{jj});
        vals{jj} = cellfun(@(x) x(jj).errOfMeans, vs{jj});
        plot(vals{jj}, '-o', 'LineWidth', 3);
    end    
%     xs = vals{xind};
%     ys = vals{yind};
%     plot(ys./xs);
%     xlabel(barNms{xind});
%     ylabel(barNms{yind});
    legend(barNms);
    legend boxoff;
    title(D.score(jj).name);
    ylim([0 2]);
end

%%

for jj = 1:5
    sc = Ss{jj};
    sc2 = Ss2{jj}
    
    S1 = {sc2(2:4).errOfMeansByKin};
    S2 = {sc(2:4).errOfMeansByKin};
    plot.init;
    for jj = [1 3]
        xs = S1{jj};
        ys = S2{jj};% - S2{2}; % deviation from pruning's scores
        plot(xs, ys, 'o');
    end
    xlabel('difference from pruning');
    ylabel('error predicting observed');
%     ylabel('error - pruning''s error');
    legend({'habitual', 'cloud'});
    title(dts{jj});
    v = axis; lo = min(v(1:2:end)); up = max(v(2:2:end)); axis([lo up lo up]);
end
    
