

dts = {'20131125'};
% dts = {'20120525', '20120601', '20120709', '20131212', '20131205', '20131125'};
% dts = {'20120601', '20120709', '20131212', '20131205', '20131125'};

binSz = 100;
binSkp = binSz/2;
binNm = 'trial_index';

% binSz = 15;
% binSkp = 15;
% binNm = 'angError';

nms = {'kinematics mean', 'cloud-hab'};
fldr = fullfile('plots', 'behaviorAndHypotheses', ['errorBy-' binNm]);
askedOnce = false;
doSave = false;
doKins = true;

params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360);
for jj = 1:numel(dts)
    D = fitByDate(dts{jj}, params, nms);

    xs1 = min(D.blocks(2).trial_index);
    xs2 = max(D.blocks(2).trial_index);
%     xs1 = -120; xs2 = 120;
    
    tbins = xs1:binSkp:(xs2-binSz);
    [doSave, askedOnce] = plot.hypothesisErrorByTime(D, binNm, tbins, ...
        binSz, doKins, fldr, doSave, askedOnce);
    
end
