
B1 = D.blocks(2);
B2 = D.blocks(1);
T = B1.thetas + 180;
Z = B1.latents;
targs = B1.targetAngle;
alltrg = unique(targs);
ntrgs = numel(alltrg);

NB = null(B1.fDecoder.M2);
ZN = Z*NB;

Ak = [alltrg - 22.5 alltrg + 22.5];
Ak(Ak < 0) = 360 + Ak(Ak < 0);
bnds = Ak;
Grp = nan(size(ZN,1),1);
Y = [];
for ii = 1:ntrgs
    ix = tools.targsInRange(T, bnds(ii,:));
    Grp(ix) = ii;
    Y = [Y; ZN(ix,:)];
end

%% discriminate target (two options) using null space activity

X1 = ZN(targs == alltrg(1),:);
X2 = ZN(targs == alltrg(4),:);
lbl = [ones(size(X1,1),1); 2*ones(size(X2,1),1)];
mdl = fitcdiscr([X1; X2], lbl);
disp('----')
cvmodel = crossval(mdl, 'kfold', 5);
cverror = kfoldLoss(cvmodel)

%% discriminate targets using null space activity

mdl = fitcdiscr(ZN, targs);
disp('----')
cvmodel = crossval(mdl, 'kfold', 5);
cverror = kfoldLoss(cvmodel)

%% discriminate kinematics condition using null space activity

mdl = fitcdiscr(Y, Grp);

disp('----')
cvmodel = crossval(mdl, 'kfold', 5);
cverror = kfoldLoss(cvmodel)

