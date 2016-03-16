

% dts = {'20120709'};
dts = {'20120525', '20120601', '20120709', '20131212', '20131205', '20131125'};
% dts = {'20120601', '20120709', '20131212', '20131205', '20131125'};

binSz = 100;
binSkp = binSz/2;
binNm = 'trial_index';
% 
% binSz = 15;
% binSkp = 15;
% binNm = 'angError';

fldr = fullfile('plots', 'hypErrorByTime');
suff = '';
askedOnce = false;

params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360);
for jj = 1:numel(dts)
    dtstr = dts{jj}
    D = io.quickLoadByDate(dtstr, params);
    xs1 = min(D.trials.trial_index(D.trials.block_index == 2));
    xs2 = max(D.trials.trial_index(D.trials.block_index == 2));
    
%     xs1 = -120; xs2 = 120;
    
    tbins = xs1:binSkp:(xs2-binSz);
    
    D.hyps = pred.addPrediction(D, 'observed', D.blocks(2).latents);
    D.hyps = pred.addPrediction(D, 'kinematics mean', pred.cvMeanFit(D, true));
    D.hyps = pred.addPrediction(D, 'habitual', pred.habContFit(D));
    D.hyps = pred.addPrediction(D, 'cloud-hab', pred.sameCloudFit(D, 0.35, 30));
    
    errMus = nan(numel(tbins), 3);
    ns = nan(size(errMus,1),1);
    errCovsShape = nan(size(errMus));
    errCovsOrient = nan(size(errMus));
    for ii = 1:numel(tbins)
        t1 = tbins(ii); t2 = tbins(ii)+binSz;
        ts = D.blocks(2).(binNm);
        D.blocks(2).idxScore = ts >= t1 & ts < t2;
        ns(ii) = sum(D.blocks(2).idxScore);
        D = pred.nullActivity(D, 'idxScore');
        D = score.scoreAll(D);
        errMus(ii,:) = [D.hyps(2:end).errOfMeans];
    end

    figure; set(gcf, 'color', 'w');
    hold on; set(gca, 'FontSize', 14);

    for ii = 1:size(errMus,2)
        plot(tbins, errMus(:,ii));%/ns(ii));
    end
    plot(tbins, ns/max(ns), 'k--');
    xlabel(binNm);
    ylabel('errMus');
    legend({D.hyps(2:end).name});
    title(dtstr);
    
    if ~isempty(fldr)
        fnm = fullfile(fldr, [D.datestr '_' suff]);
        if exist(fnm, 'file')
            resp = input('Files exist. Continue?', 's');
            askedOnce = true;
            if ~strcmpi(resp(1), 'y')
                error('Quitting because you didn''t want to save.');
            end
        end
%         save
    end
end
