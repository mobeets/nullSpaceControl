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
        
        pos_ime = imefit.cursorIme(D.blocks(ii), D.ime(ii));
        [ths_ime, angErr_ime] = addImeStats(D.blocks(ii), pos_ime);
        D.blocks(ii).posIme = pos_ime;
        D.blocks(ii).thetasIme = ths_ime;
        D.blocks(ii).angErrorIme = angErr_ime;
    end
end

function [ths_ime, angErr_ime] = addImeStats(B, pos_ime)
    vec2trg = B.target - pos_ime;
    movVec = diff(pos_ime); % or do we compare true pos to next pos_ime?
    
    ths_ime = arrayfun(@(t) tools.computeAngle(vec2trg(t,:), [1; 0]), ...
        1:size(vec2trg,1));
    ths_ime = mod(ths_ime, 360);
    
    angErr_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), ...
        vec2trg(t,:)), 1:size(vec2trg,1)-1);
    angErr_ime = [angErr_ime nan]; % for last time step
end
