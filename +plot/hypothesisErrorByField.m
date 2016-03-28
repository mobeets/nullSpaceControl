function [errMus, ns, allErrMus, errMusKins, allErrMusKins, nsKins] = ...
    hypothesisErrorByField(D, binNm, tbins, binSz, extraNm, hypopts)
    if nargin < 5
        extraNm = '';
    end
    if nargin < 6
        hypopts = struct();
    end
    errName = 'errOfMeans';
    errKinName = [errName 'ByKin'];
    
    D = pred.nullActivity(D, hypopts);
    D = score.scoreAll(D);
    allErrMus = [D.hyps(2:end).(errName)];
    allErrMusKins = cell2mat({D.hyps(2:end).(errKinName)}');

    hypopts.idxFldNm = 'idxScore';
    
    nhyps = numel(D.hyps)-1;
    errMus = nan(numel(tbins), nhyps);
    ns = nan(size(errMus,1),1);
    kins = score.thetaCenters(8);
    nkins = numel([D.hyps(2).(errKinName)]);
    errMusKins = cell(nkins, 1);
    nsKins = cell(nkins,1);
    for ii = 1:numel(errMusKins)
        errMusKins{ii} = nan(size(errMus));
        nsKins{ii} = nan(size(ns));
    end    
    for ii = 1:numel(tbins)
        t1 = tbins(ii); t2 = tbins(ii)+binSz;
        ts = D.blocks(2).(binNm);
        D.blocks(2).idxScore = ts >= t1 & ts < t2;
        if isempty(extraNm)
            ns(ii) = sum(D.blocks(2).idxScore);
        else
            vs0 = D.blocks(2).(extraNm);
            ns(ii) = nanmean(vs0(D.blocks(2).idxScore));
        end
        D = pred.nullActivity(D, hypopts);
        D = score.scoreAll(D);
        errMus(ii,:) = [D.hyps(2:end).(errName)];
        
        % note: want each one of these like errMus
        scs = cell2mat({D.hyps(2:end).(errKinName)}');
        for jj = 1:nkins
            errMusKins{jj}(ii,:) = scs(:,jj)';
            nsKins{jj}(ii) = sum(D.blocks(2).idxScore & D.blocks(2).thetaGrps == kins(jj));
        end
        
%         ps = params; ps.START_SHUFFLE = t1; ps.END_SHUFFLE = t2;
% %         tA = min(abs(t1), abs(t2)); tB = max(abs(t1), abs(t2));
% %         ps = params; ps.MIN_ANGULAR_ERROR = tA; ps.MAX_ANGULAR_ERROR = tB;
%         E = io.quickLoadByDate(dtstr, ps);
%         E.hyps = pred.addPrediction(E, 'observed', E.blocks(2).latents);
%         E.hyps = pred.addPrediction(E, 'kinematics mean', pred.cvMeanFit(E, true));
%         E = pred.nullActivity(E);
%         E = score.scoreAll(E);
%         errMus(ii,1) = E.hyps(2).errOfMeans;
    end
end
    