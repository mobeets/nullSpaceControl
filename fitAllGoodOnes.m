
dts = {'20120601', '20120709', '20131212', '20120525'};
params = struct('MAX_ANGULAR_ERROR', 360);
hyps = {'kinematics mean', 'habitual', 'cloud-hab', 'baseline', ...
    'minimum', 'unconstrained', 'volitional-w-2FAs', ...
    'volitional-w-2FAs (s=5)'};

% hyps = {'habitual'};
for ii = 1:numel(dts)
    close all;
    dtstr = dts{ii};
    D = fitByDate(dtstr, [true false true], params, hyps);
end

%%

for ii = 1:numel(dts)
    close all;
    dtstr = dts{ii}
    ps = io.setFilterDefaults(dtstr);
    ps0 = struct('START_SHUFFLE', nan, ...
        'END_SHUFFLE', ps.START_SHUFFLE, 'MAX_ANGULAR_ERROR', 360)
    D = fitByDate(dtstr, [true false true], ps0);
end

%%

% dts = {'20131212'};%, '20131205'}; 20131125
dts = {'20120525', '20120601', '20120709', '20131212'};
for jj = 2%1:numel(dts)
    dtstr = dts{jj}
    D = io.quickLoadByDate(dtstr, struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360));
    xs1 = min(D.trials.trial_index(D.trials.block_index == 2));
    xs2 = max(D.trials.trial_index(D.trials.block_index == 2));
%     tbins = xs1:50:xs2;
    tbins = xs1:100:(xs2-100);

    errMus = nan(numel(tbins)-1, 3);
    errCovsShape = nan(size(errMus));
    errCovsOrient = nan(size(errMus));
    for ii = 1:numel(tbins)
        params = struct('MAX_ANGULAR_ERROR', 360, ...
            'START_SHUFFLE', tbins(ii), 'END_SHUFFLE', tbins(ii)+100);
        D = io.quickLoadByDate(dtstr, params);
        D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
        D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
        D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
        D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
        
        D = pred.nullActivity(D);
        D = score.scoreAll(D);
        errMus(ii,:) = [D.hyps(2:end).errOfMeans];
        errCovsShape(ii,:) = [D.hyps(2:end).covErrorOrient];
        errCovsOrient(ii,:) = [D.hyps(2:end).covErrorShape];
    end

    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);

    for ii = 1:size(errMus,2)
        plot(tbins, errMus(:,ii));
    end
    xlabel('xstart');
    ylabel('errMus');
    legend({D.hyps(2:end).name});
    title(dtstr);

end
