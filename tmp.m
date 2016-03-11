params = struct('START_SHUFFLE', nan, 'MAX_ANGULAR_ERROR', 360, ...
    'REMOVE_INCORRECTS', true);

dtstr = '20120601';
D = io.quickLoadByDate(dtstr, params, false);
D.trials = tools.concatBlocks(D);
grpName = 'targetAngle';
nms = {'progress', 'trial_length'};
fcns = {[], []};
collapseTrials = [true true];
nm = '-';

B = D.blocks(2);
progressOrth = nan(size(B.progress));
targDist = nan(size(progressOrth));
for t = 1:numel(B.progress)
    moveTime(t) = D.simpleData.movementTime(B.trial_index(t));
    targDist(t) = norm(B.pos(t,:) - B.target(t,:));
    vec2trg = B.vec2target(t,:);
    vec2trgOrth(1) = vec2trg(2);
    vec2trgOrth(2) = -vec2trg(1);
    movVec = D.trials.movementVector(t,:);
    progressOrth(t) = -(movVec*vec2trgOrth'/norm(vec2trg));
end
D.blocks(2).progressOrth = progressOrth;
D.blocks(2).targDist = targDist;
D.blocks(2).moveTime = moveTime;

% [X,Y,N,fits] = plot.createBehaviorPlots(D, blockInd, grpName, nms, ...
%     binSz, ptsPerBin, collapseTrials, fcns, false);
%%

B = D.blocks(2);
% ix = B.targetAngle == 180;
% ix = B.targetAngle == 270;
ix = B.targetAngle == 225;
ts = B.trial_index(ix);
xs = B.trial_length(ix);
ys = B.progress(ix);
zs = B.targDist(ix);


% close all;
figure; set(gcf, 'color', 'w');

subplot(2,1,1);
hold on; set(gca, 'FontSize', 14);

trs = sort(unique(ts));
X = nan(max(trs), 1);
Y = nan(size(X));
Z = nan(size(X));
T = 1:max(trs);
for ii = 1:numel(trs)
    t = trs(ii);
    it = ts == t;
    x = nanmean(xs(it));
    y = ys(it);
    z = zs(it);

    plot(x, nanmean(y), 'ok');
%     plot(nanmean(z), nanmean(y), 'ok');
%     plot(nanmean(z), x, 'ok');
    
    X(t) = x;
    Y(t) = nanmean(y);
    Z(t) = nanmean(z);
end
% plot(zs, ys, '.k');
% [~,iz] = sort(zs);
% plot(zs(iz), smooth(zs(iz), ys(iz), 20), '-k');
xlabel('trial_length');
ylabel('progress');

subplot(2,1,2);
hold on; set(gca, 'FontSize', 14);
itx = ~isnan(X);
ity = ~isnan(Y);
itz = ~isnan(Z);
% 
% plot(T(itz), Z(itz)./nanmax(Z), '.');
% plot(T(ity), Y(ity)./nanmax(Y), '.');
% plot(T(itz), Z(itz)./nanmax(Z), 'b-');
% plot(T(ity), Y(ity)./nanmax(Y), 'r-');

plot(T(itx), X(itx)./nanmax(X), '.');
plot(T(ity), Y(ity)./nanmax(Y), '.');
plot(T(itx), smooth(T(itx), X(itx)./nanmax(X)), 'b-');
plot(T(ity), smooth(T(ity), Y(ity)./nanmax(Y)), 'r-');

xlabel('trial #');
ylabel('value');

%%

% trial_length > 80
% progress > 15

tx = T(X > 80);
ty = T(Y > 15);
figure; plot.showTrial(D.simpleData, tx);
figure; plot.showTrial(D.simpleData, ty);

figure; plot.showTrial(D.simpleData, T(Y > 15), {'movementTime'});

