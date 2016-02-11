
[Z, Zpre, Zvol] = pred.volContFit(D, true, 2);
%%
B1 = D.blocks(1);
B2 = D.blocks(2);
NB2 = B2.fDecoder.NulM2;
cs = nan(size(Zvol,1),1);
options = optimset('Display', 'off');
for t = 1:size(Zvol,1)
    fcn = @(c) norm((Zpre(t,:) + Zvol(t,:)/c - B2.latents(t,:))*NB2);
    cs(t) = fminunc(fcn, 1, options);
%     cs(t) = B2.latents(t,:)*Zvol(t,:)'/norm(Zvol(t,:));
%     cs(t) = norm(B2.latents(t,:) - Zvol(t,:));
end

%%

close all;
figure; hist(cs, 30)
figure; hist(cs(cs<20), 30)

%%

vs1 = arrayfun(@(ii) norm(Zvol(ii,:)), 1:size(Zvol,1));
vs2 = arrayfun(@(ii) norm(Zvol(ii,:)/5), 1:size(Zvol,1));
vs3 = arrayfun(@(ii) norm(Zpre(ii,:)), 1:size(Zpre,1));
vs4 = arrayfun(@(ii) norm(Zpre(ii,:) + Zvol(ii,:)/3), 1:size(Zpre,1));
vs5 = arrayfun(@(ii) norm(B2.latents(ii,:)), 1:size(B2.latents,1));

close all;
figure; 
hist(vs1);

% figure; 
% hist(vs5);

%% 

normall = @(z) arrayfun(@(ii) norm(z(ii,:)), 1:size(z,1));

obs = normall(D.hyps(1).latents);
hab = normall(D.hyps(2).latents);
vol2 = normall(D.hyps(3).latents);
vol2a = normall(D.hyps(4).latents);
vol3 = normall(D.hyps(5).latents);
vol3a = normall(D.hyps(6).latents);

ymx = max([max(obs), max(hab), max(vol2), max(vol2a), max(vol3), max(vol3a)]);
bins = linspace(0, ymx, 30);

nn = 6;
figure;
subplot(1,nn,1); hold on;
hist(obs, bins);
subplot(1,nn,2); hold on;
hist(hab, bins);
subplot(1,nn,3); hold on;
hist(vol2, bins);
subplot(1,nn,4); hold on;
hist(vol2a, bins);
subplot(1,nn,5); hold on;
hist(vol3, bins);
subplot(1,nn,6); hold on;
hist(vol3a, bins);
