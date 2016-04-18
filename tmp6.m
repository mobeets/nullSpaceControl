
dtstr = '20120525';
% dtstr = '20120601';
% dtstr = '20120709';
% dtstr = '20131125';
% dtstr = '20131205';
hnms = {'true', 'zero', 'habitual', 'unconstrained', ...
    'cloud-hab', 'condnrm', 'condnrmkin'};
% hnms = {'true', 'zero', 'habitual', 'volitional', 'unconstrained'};
% hnms = {'true', 'zero', 'cloud-hab', 'condnrm', 'condnrmkin'};
% hnms = {'true', 'zero', 'habitual', 'cloud-hab', 'condnrm', ...
%     'condnrmkin', 'volitional', 'unconstrained'};
D = fitByDate(dtstr, [], hnms, [], [], struct('decoderNm', 'fImeDecoder'));

inds = 2:numel(D.hyps);
% inds = [2 3 4 5 8 9 10];
figure; plot.errorByKin(D.hyps(inds), 'errOfMeansByKin'); title(D.datestr);
% figure; plot.errorByKin(D.hyps(inds), 'covErrorOrientByKin'); title(D.datestr);
% figure; plot.errorByKin(D.hyps(inds), 'covErrorShapeByKin'); title(D.datestr);

%%

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    dtstr = dts{ii}
    hnms = {'true', 'zero', 'cloud-hab', 'condnrm'};
    D = fitByDate(dtstr, [], hnms, [], [], struct('decoderNm', 'fDecoder'));
    D2 = fitByDate(dtstr, [], hnms, [], [], struct('decoderNm', 'fImeDecoder'));

    inds = 2:numel(D.hyps);
    figure;
    subplot(1,2,1); hold on;
    plot.errorByKin(D.hyps(inds), 'errOfMeansByKin'); title(D.datestr);
    title([D.datestr ': true decoder']);
    subplot(1,2,2); hold on;
    plot.errorByKin(D2.hyps(inds), 'errOfMeansByKin'); title(D.datestr);
    title([D.datestr ': IME']);
end

%%

decNm = 'fImeDecoder';
opts = struct('D', D, 'showPts', false, 'decoderNm', decNm, ...
    'doNull', false, 'showCov', false);
NB = D.blocks(2).(decNm).NulM2;
Y = D.hyps(1).latents;
[~,~,v] = svd(Y*NB); NB = NB*v;
Y = Y*NB;

for ii = 1:numel(hnms)
    hyp = pred.getHyp(D, hnms{ii});
    Yh = hyp.latents*NB;
    
    figure;
    opts.markerStr = 'ko';
    plot.visualize3d(Y, opts);    
    opts.markerStr = 'ws';
    plot.visualize3d(Yh, opts);
    
    axis off;
    title([D.datestr ' ' hyp.name]);
end

%%

hyp = pred.getHyp(D, 'condnrm');
Y1 = D.hyps(1).latents;
Y2 = hyp.latents;

decNm = 'fDecoder';
dec = D.blocks(2).(decNm);
[~,Y1c] = tools.latentsInBasis(Y1, dec.NulM2, dec.RowM2);
[~,Y2c] = tools.latentsInBasis(Y2, dec.NulM2, dec.RowM2);

gs = D.blocks(2).thetaGrps;

% only show best and worst
[~,ix1] = min(hyp.errOfMeansByKin);
[~,ix2] = max(hyp.errOfMeansByKin);
grps = sort(unique(gs));
ixBestOrWorst = (gs == grps(ix1)) | (gs == grps(ix2));
Y1c = Y1c(ixBestOrWorst,:);
Y2c = Y2c(ixBestOrWorst,:);
gs = gs(ixBestOrWorst);

% figure;
mopts = struct('splitKinsByFig', true, 'h1', 0.1/4, 'h2', 0.1/4);
plot.marginals(Y1c, Y2c, gs, [], mopts);
plot.subtitle([D.datestr ': ' hyp.name]);
