
D = io.quickLoadByDate('20131218');

%%

isIme = true;

if isIme
    spsDecNm = 'nImeDecoder';
    facDecNm = 'fImeDecoder';
    vNm = 'velIme';
    vNmNext = 'velNextIme2';
else
    spsDecNm = 'nDecoder';
    facDecNm = 'fDecoder';
    vNm = 'vel';
    vNmNext = 'velNext';
end

B = D.blocks(2);
Ys = B.spikes;
Yf = B.latents;

sdec = B.(spsDecNm);
Ac = sdec.M1;
Bc = sdec.M2;
cc = sdec.M0;

fdec = B.(facDecNm);
Af = fdec.M1;
Bf = fdec.M2;
cf = fdec.M0;

vel = B.(vNm);
velNext = B.(vNmNext);

nt = size(Ys,1);
errs_sps = nan(nt,1);
errs_fcs = nan(nt,1);
for t = 1:nt
    x0 = vel(t,:)';
    x1 = velNext(t,:)';
    
    beq = x1 - Ac*x0 - cc;
    errs_sps(t) = norm(beq - Bc*Ys(t,:)');
    
    beq = x1 - Af*x0 - cf;
    errs_fcs(t) = norm(beq - Bf*Yf(t,:)');
end

nanmedian(errs_sps)
nanmedian(errs_fcs)
