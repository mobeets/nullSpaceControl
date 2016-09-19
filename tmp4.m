
Dc = D.simpleData.nullDecoder;
L = Dc.FactorAnalysisParams.L;
ph = Dc.FactorAnalysisParams.ph;
mu = Dc.spikeCountMean;
sigmainv = diag(1./Dc.spikeCountStd);
if isfield(Dc.FactorAnalysisParams, 'spikeRot')
    R = Dc.FactorAnalysisParams.spikeRot;
else
    R = eye(size(L,2));
end
beta = L'/(L*L'+diag(ph)); % See Eqn. 5 of DAP.pdf
beta = R'*beta*sigmainv';

spikes = D.blocks(1).spikes;
lts = D.blocks(1).latents;

u = bsxfun(@plus, spikes, -mu);
latents = u*beta';

u1 = spikes*beta';
u2 = -mu*beta';
latents = bsxfun(@plus, spikes*beta', -mu*beta');

max(abs(sum((lts - latents).^2,2)))

%%

dec = D.blocks(1).fDecoder;
Ac = dec.M1;
Bc = dec.M2;
cc = dec.M0;

nt = numel(D.blocks(1).time);
errs2 = nan(nt,1);

for t = 1:nt
    x0 = D.blocks(1).vel(t,:)';
    x1 = D.blocks(1).velNext(t,:)';
    
    Aeq = Bc*beta;
    beq = x1 - Ac*x0 - cc + Aeq*mu';
    
    u = D.blocks(1).spikes(t,:)';
    errs2(t) = norm(beq - Aeq*u);

end

