function D = addImeDecoders(D)
    fnm = io.pathToIme(D.datestr);
    if ~exist(fnm, 'file')
        return;        
    end
    x = load(fnm);
    D.ime = x.ime;
    dt = 1/0.045; % 1/(sec per timestep)
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
        
        [pos_ime, ths_ime] = imefit.cursorIme(D.blocks(ii), D.ime(ii));
        D.blocks(ii).posIme = pos_ime;
        D.blocks(ii).thetasIme = ths_ime;
    end
end
