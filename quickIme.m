
dtstr = '20120525';
% dtstr = '20120601';
D = io.quickLoadByDate(dtstr);

%%

% nms = {'kinematics mean', 'habitual', 'cloud-hab'};%, 'unconstrained', 'volitional-w-2FAs'};
nms = {'minimum', 'baseline'};

decNm = 'nDecoder';
hypopts = struct('decoderNm', decNm);
D = pred.fitHyps(D, nms, hypopts);
hypopts = struct('decoderNm', ['f' decNm(2:end)]);
D = pred.nullActivity(D, hypopts);
D = score.scoreAll(D);
plot.plotScores(D, [D.datestr '-' decNm]);
[D.hyps.errOfMeans]

decNm = 'nImeDecoder';
hypopts = struct('decoderNm', decNm);
D = pred.fitHyps(D, nms, hypopts);
hypopts = struct('decoderNm', ['f' decNm(2:end)]);
D = pred.nullActivity(D, hypopts);
D = score.scoreAll(D);
plot.plotScores(D, [D.datestr '-' decNm]);
[D.hyps.errOfMeans]
