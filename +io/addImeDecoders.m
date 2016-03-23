function D = addImeDecoders(D)
    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'ime', [D.datestr '.mat']);
    if ~exist(fnm, 'file')
        return;        
    end
    x = load(fnm);
    D.ime = x.ime;
    dt = 0.045; % sec per timestep
    for ii = 1:numel(D.ime)
        dec = D.ime(ii);
        dec.M0 = dec.b0*dt;
        dec.M1 = dec.A;
        dec.M2 = dec.B*dt;
        [dec.NulM2, dec.RowM2] = tools.getNulRowBasis(dec.M2);
        D.blocks(ii).nImeDecoder = dec;
        
        % convert to factor decoder
        fdec = tools.spikeDecoderToFactorDecoder(dec, ...
            D.simpleData.nullDecoder);
        [fdec.NulM2, fdec.RowM2] = tools.getNulRowBasis(fdec.M2);
        D.blocks(ii).fImeDecoder = fdec;
    end
end
