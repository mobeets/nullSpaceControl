function d = rawSpikesToLatentsByBlock(d)

latents = cell(1, d.NBLOCKS);
for ii = 1:d.NBLOCKS
    latents{ii} = io.convertRawSpikesToRawLatents(d.simpleData, ...
        d.spikes{ii});
end
d.latents = latents;

end
