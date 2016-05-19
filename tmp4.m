
dtstr = '20120525';
nms = {'habitual', 'cloud-hab', 'cloud-raw', 'unconstrained'};
D = fitByDate(dtstr, [], nms);

%%

inds = 2:numel(D.hyps);
% inds = [3 4 8];
figure;
subplot(2,1,1); plot.errorByKin(D.hyps(inds), 'errOfMeansByKin', [], 'se');
subplot(2,1,2); plot.errorByKin(D.hyps(inds), 'covErrorByKin', [], 'se');

figure; plot.meanErrorByKinByCol(D, pred.getHyp(D, 'pruning'));

%%

gs = D.blocks(2).thetaActualGrps;
Zs = cell(numel(D.hyps),1);
for ii = 1:numel(D.hyps)
    Y = D.hyps(ii).latents;
    if ii == 1
        [Zs{ii}, Xs, grps] = tools.marginalDist(Y, gs);
    else
        Zs{ii} = tools.marginalDist(Y, gs, [], Xs);
    end
end

lfcn = @(y,yh) sqrt(mean((y-yh).^2));

nitems = numel(Zs);
ngrps = numel(Zs{1});
ncols = size(Zs{1}{1},2);
errs = nan(ngrps, ncols, nitems-1);
for ii = 1:ngrps
    for jj = 1:ncols
        for kk = 2:nitems % items
            Z0 = Zs{1}{ii}(:,jj);
            Z = Zs{kk}{ii}(:,jj);
            errs(ii,jj,kk-1) = lfcn(Z0, Z);
        end
    end
end

%%

errs = squeeze(sum(errs,2)); % columns of errs is mean rmse error per grp
plot.marginalDists(Zs, Xs, grps);
plot.init; plot.valsByGrp(errs', grps, {D.hyps(2:end).name});
