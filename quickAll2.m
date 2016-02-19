
dts = {'20120525', '20120601', '20131125', '20131205'};
Bs = cell(numel(dts),1);
scs = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.loadDataByDate(dtstr);
    D.params = io.setFilterDefaults(D.params);
    D.params.MAX_ANGULAR_ERROR = 360;
    D.blocks = io.getDataByBlock(D);
    D.blocks = pred.addTrainAndTestIdx(D.blocks);
    D = io.addDecoders(D);
    D = tools.rotateLatentsUpdateDecoders(D, true);
    
    B = D.blocks(2);
    B.datestr = D.datestr;
    Bs3{ii} = B;
    continue;
    
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    D.hyps = pred.addPrediction(D, 'volitional w/ 2Fs', ...
        pred.volContFit(D, true, 2));
    D.hyps = pred.addPrediction(D, 'volitional w/ 2Fs (s=5)', ...
        pred.volContFit(D, true, 2, 5));
    
    D = pred.nullActivity(D);
    D = score.scoreAll(D);
    scs{ii} = [D.hyps.errOfMeans; D.hyps.covErrorOrient; D.hyps.covErrorShape];

    B = D.blocks(2);
    B.datestr = D.datestr;
    B = rmfield(B, 'spikes');
    B.habitual = D.hyps(2).latents;
    B.volitional = D.hyps(3).latents;
    B.volitionalScale = D.hyps(4).latents;
%     B.angErrorOG = D.blocks(1).angError;
%     B.thetaGrpsOG = D.blocks(1).thetaGrps;
    Bs{ii} = B;
    
end

%% add null activity

for ii = 1:numel(Bs)
    B = Bs{ii};
    NB = B.fDecoder.NulM2;
    [~,~,v] = svd(B.latents*NB);
    NB = NB*v;
    B.Nul = NB;
    B.habitualNul = B.habitual*NB;
    B.latentsNul = B.latents*NB;
    B.volitionalNul = B.volitional*NB;
    B.errorNul = B.habitualNul - B.latentsNul;
    B.normErrNul = arrayfun(@(ii) norm(B.errorNul(ii,:)), 1:size(B.errorNul,1))';
    B.progress = arrayfun(@(ii) B.movementVector(ii,:)*B.vec2target(ii,:)', 1:size(B.vec2target,1))';
    Bs{ii} = B;
end

%%

grps = sort(unique(Bs{1}.thetaGrps));
% clrs = cbrewer('div', 'RdYlGn', numel(grps));
clrs = cbrewer('qual', 'Set2', numel(Bs));
figure; set(gcf, 'color', 'w');
hold on; box off; set(gca, 'FontSize', 14);
for ii = 1:numel(Bs)
    B = Bs{ii};
    indEarly = prctile(B.trial_index, 20);
    indLate = prctile(B.trial_index, 80);
    ixEarly = B.trial_index <= indEarly;
    ixLate = B.trial_index >= indLate;
    for jj = 1:numel(grps)
        ix = (B.thetaGrps == grps(jj));
        xs = B.angError;
        xs = B.progress;
        xs = median(xs(ix));
%         xs = median(xs(ix & ixEarly)) - median(xs(ix & ixLate));
        ys = B.normErrNul(ix);
        ys = median(ys);
        
        ys = norm(mean(B.latents(ix,:)*B.Nul) - mean(B.habitual(ix,:)*B.Nul));
        
        scatter(xs, ys, 120, ...
            clrs(ii,:), 'o', 'filled');
    end
end
xlabel('angError');
ylabel('norm(habitual - observed)');


%% gather all errors per condition

vs = nan(numel(grps)*numel(Bs),3);
grps = sort(unique(Bs{1}.thetaGrps));
c = 1;
for ii = 1:numel(Bs)
    B = Bs{ii};
    for jj = 1:numel(grps)
        ix = (B.thetaGrps == grps(jj));
        Y = mean(B.latentsNul(ix,:));
        Yh = mean(B.habitualNul(ix,:));
        vs(c,:) = [norm(Y - Yh) ii grps(jj)];
        c = c+1;
    end
end

%% for all fields, summarize per condition

fns = fieldnames(Bs{1});

fcn = @norm; % how to collapse multiple dimensions
afcn = @nanmedian; % how to collapse multiple measurements
vss = nan(size(vs,1), numel(fns));

c = 1;
for ii = 1:numel(Bs)
    B = Bs{ii};    
    for jj = 1:numel(grps)
        ix = (B.thetaGrps == grps(jj));
        for kk = 1:numel(fns)
            fn = fns{kk};
            if isa(B.(fn), 'struct')
                continue;
            end
            xs = double(B.(fn));
            if size(xs,1) == 1 && size(xs,2) > 1
                xs = xs';
            end
            if size(xs,1) ~= size(ix)                
                continue;
            end
            xsc = xs(ix,:);
            xscc = arrayfun(@(mm) fcn(xsc(mm,:)), 1:size(xsc,1));
            vss(c,kk) = afcn(xscc);
        end
        c = c+1;
    end
end

%% compute correlations

close all;
disp('---------------');
for ii = 1:size(vss,2)
    v = corr(vs(:,1), vss(:,ii));
    if isnan(v)
        continue;
    end
    disp([fns{ii} ' = ' num2str(v)]);
    if abs(v) > 0.1
        figure;
        scatter(vss(:,ii), vs(:,1), 120, 'o', 'filled');
        xlabel(fns{ii}); ylabel('prediction error');
        title([fns{ii} ' corr = ' num2str(v)]);
    end
end

