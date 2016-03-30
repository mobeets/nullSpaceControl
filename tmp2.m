
clear all;
% close all;

D = fitByDate('20120709', [], {'habitual'}, [], [], struct('decoderNm', 'fImeDecoder'));
Y1 = D.hyps(2).latents;
NB = D.blocks(2).fDecoder.NulM2;

[u,s,v] = svd(D.blocks(1).latents*NB);
Y2 = Y1*NB*v;
Y2(:,4:end) = 0;
Y2 = Y2*v';
Y2 = Y2*NB';
D.hyps(3) = D.hyps(2);
D.hyps(3).latents = Y2;

[u,s,v] = svd(Y1*NB);
Y2 = Y1*NB*v;
Y2(:,4:end) = 0;
Y2 = Y2*v';
Y2 = Y2*NB';
D.hyps(4) = D.hyps(2);
D.hyps(4).latents = Y2;

D = pred.nullActivity(D);
D = score.scoreAll(D);

figure; plot.allErrorByKin(D, D.hyps(2:end))

%%

% hypopts = struct('decoderNm', 'fImeDecoder'));
D = fitByDate('20120601', ...
    {'cloud-hab', 'conditional', 'conditional-thetas'}, ...
    [], hypopts);
figure; plot.allErrorByKin(D, D.hyps(2:end))
