

D = io.quickLoadByDate('20131218');
%%

isIme = true;

if isIme
    spsDecNm = 'nImeDecoder';
    facDecNm = 'fImeDecoder';
    vNm = 'velIme';
    vNmNext = 'velNextIme';
else
    spsDecNm = 'nDecoder';
    facDecNm = 'fDecoder';
    vNm = 'vel';
    vNmNext = 'velNext';
end

B = D.blocks(2);
Ys = B.spikes;
Yf = B.latents;
% RBs = B.nDecoder.RowM2;
% RBf = B.fDecoder.RowM2;
RBs = B.(spsDecNm).M2';
RBf = B.(facDecNm).M2';

dec = B.(spsDecNm);
Ac = dec.M1;
Bc = dec.M2;
cc = dec.M0;

vel = B.(vNm);
velNext = B.(vNmNext);

dt = 0.045;

nt = size(Ys,1);
errs = nan(nt,1);
for t = 8%:nt
    x0 = vel(t,:)';
    x1 = velNext(t,:)';
    Aeq = Bc;
    beq = x1 - Ac*x0 - cc;
    
    [x1 - (Ac*x0 + Bc*Ys(t,:)' + cc)]
    
    errs(t) = norm(beq - Aeq*Ys(t,:)');
end

nanmedian(errs)
