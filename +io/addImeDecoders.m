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
        
        [pos_ime, vel_ime] = imefit.cursorIme(D.blocks(ii), D.ime(ii));
        [ths_ime, angErr_ime, thsact_ime] = addImeStats(D.blocks(ii), ...
            pos_ime, vel_ime);
        D.blocks(ii).posIme = pos_ime;
        D.blocks(ii).velIme = vel_ime;
        D.blocks(ii).thetasIme = ths_ime;
        D.blocks(ii).thetaActualsIme = thsact_ime;
        D.blocks(ii).angErrorIme = angErr_ime;
        D.blocks(ii).thetaImeGrps = score.thetaGroup(ths_ime, ...
            score.thetaCenters(8));
        D.blocks(ii).thetaImeGrps16 = score.thetaGroup(ths_ime, ...
            score.thetaCenters(16));
        D.blocks(ii).thetaActualImeGrps = score.thetaGroup(thsact_ime, ...
            score.thetaCenters(8));
        D.blocks(ii).thetaActualImeGrps16 = score.thetaGroup(thsact_ime, ...
            score.thetaCenters(16));
    end
end

function [ths_ime, angErr_ime, thsact_ime] = addImeStats(B, pos_ime, vel_ime)
    vec2trg = B.target - pos_ime;
%     movVec = diff(pos_ime); % or do we compare true pos to next pos_ime?
    movVec = vel_ime; % must also comment out line 57
    
    ths_ime = arrayfun(@(t) tools.computeAngle(vec2trg(t,:), [1; 0]), ...
        1:size(vec2trg,1))';
    ths_ime = mod(ths_ime, 360);
    
    angErr_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), ...
        vec2trg(t,:)), 1:size(vec2trg,1)-1);
    angErr_ime = [angErr_ime nan]'; % for last time step
    
    thsact_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), [1; 0]), ...
        1:size(movVec,1))';
%     thsact_ime = [thsact_ime; nan]; % for last time step
    thsact_ime = mod(thsact_ime, 360);

    % thsact_ime needs to change at the or of the below;
    % (because time and trial changes have already been filtered out,
    % movVec's diff above is off)
    ix = diff(B.trial_index) ~= 0 | diff(B.time) ~= 1;
    thsact_ime(ix) = nan;
    angErr_ime(ix) = nan;
end
