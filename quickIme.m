
dtstr = '20120525';
% dtstr = '20120601';
% dtstr = '20120709';
D = io.quickLoadByDate(dtstr);

%%

nms = {'kinematics mean', 'habitual', 'cloud-hab', 'unconstrained'};%, 'volitional-w-2FAs'};
% nms = {'minimum', 'baseline'};

decNm = 'fDecoder';
hypopts = struct('decoderNm', decNm);
D = pred.fitHyps(D, nms, hypopts);
D = pred.nullActivity(D, hypopts);
D = score.scoreAll(D);
plot.plotScores(D, [D.datestr '-' decNm]);
[D.hyps.errOfMeans]

decNm = 'fImeDecoder';
hypopts = struct('decoderNm', decNm);
D = pred.fitHyps(D, nms, hypopts);
D = pred.nullActivity(D, hypopts);
D = score.scoreAll(D);
plot.plotScores(D, [D.datestr '-' decNm]);
[D.hyps.errOfMeans]
