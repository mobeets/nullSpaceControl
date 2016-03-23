D = io.quickLoadByDate('20120601');
sps1 = D.blocks(1).spikes;

niters = 10;
vs = nan(niters,1);
for ii = 1:niters
    sps0 = sps1;
    lts0 = tools.convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps0');
    sps1 = tools.latentsToSpikes(lts0, D.simpleData.nullDecoder, false);
    lts1 = tools.convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps1');
%     v = mean(sqrt(sum((sps0 - sps1).^2,2)));
    v = mean(sqrt(sum((lts0 - lts1).^2,2)));
    vs(ii) = v;
end
vs(1:10)

% ss = vs;
