D = io.quickLoadByDate(dtstr);
sps1 = D.blocks(1).spikes;

niters = 100;
vs = nan(niters,1);
for ii = 1:niters
    sps0 = sps1;
    lts0 = tools.convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps0');
    sps1 = tools.latentsToSpikes(lts0, D.simpleData.nullDecoder);
    lts1 = tools.convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps1');
    v = mean(sqrt(sum((sps0 - sps1).^2,2)))
    vs(ii) = v;
end
