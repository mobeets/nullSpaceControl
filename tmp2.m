

% FA params
decoder = D.simpleData.nullDecoder;
L = decoder.FactorAnalysisParams.L;    
ph = decoder.FactorAnalysisParams.ph;
mu = decoder.spikeCountMean';
sigmainv = diag(1./decoder.spikeCountStd');
if isfield(decoder.FactorAnalysisParams, 'spikeRot')
    R = decoder.FactorAnalysisParams.spikeRot;
else
    R = eye(size(L,2));
end
beta = L'/(L*L'+diag(ph));

df = D.blocks(1).fDecoder;
A = df.M1;
B = df.M2;
c = df.M0;

dn = D.blocks(1).nDecoder;
An = dn.M1;
Bn = dn.M2;
cn = dn.M0;

Bn2 = B*R'*beta*sigmainv;
cn2 = -Bn2*mu + c;

%%

[NB, RB] = tools.getNulRowBasis(B);

Bn2 = B*R'*beta*sigmainv;
[NBn, RBn] = tools.getNulRowBasis(Bn2);
