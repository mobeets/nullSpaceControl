function D = swapNulRow(D)
    for ii = 1:numel(D.blocks)
        NB = D.blocks(ii).fDecoder.NulM2;
        RB = D.blocks(ii).fDecoder.RowM2;
        D.blocks(ii).fDecoder.NulM2 = RB;
        D.blocks(ii).fDecoder.RowM2 = NB;
    end
end
