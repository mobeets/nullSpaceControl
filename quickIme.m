
dtstr = '20120525';
% dtstr = '20120601';
D = io.quickLoadByDate(dtstr);

%%

nms = {'kinematics mean', 'habitual', 'cloud-hab', 'volitional-w-2FAs'};

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
