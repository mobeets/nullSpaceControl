

B1 = D.blocks(1);
B2 = D.blocks(2);

clr1 = [0.2 0.2 0.8];
clr2 = [0.8 0.2 0.2];

clrA = clr1;
BlkA = B1;
BlkB = B2;

T = BlkA.thetas + 180;
Z = BlkA.latents;
% Z = D.hyps(7).latents;
targs = BlkA.targetAngle;

vels = BlkA.movementVector;
velAng = arrayfun(@(ii) atan2d(vels(ii,2), vels(ii,1)), 1:size(vels,1));
% T = abs(velAng - 180);

ix0 = BlkA.trial_index > prctile(BlkA.trial_index, [25]) & ...
    BlkA.trial_index < prctile(BlkA.trial_index, [75]);
ix1 = BlkA.trial_index >= prctile(BlkA.trial_index, [90]);
ix2 = BlkA.trial_index <= prctile(BlkA.trial_index, [10]);
ix3 = true(size(BlkA.time));
ixA = ix3;
T = T(ixA);
targs = targs(ixA);
Z = Z(ixA,:);

NB = BlkA.fDecoder.NulM2;
ZN = Z*NB;
% ZN = Z;

alltrg = unique(targs);
ntrgs = numel(alltrg);
alltrg = circshift(alltrg, floor(ntrgs/2));
cmap = cbrewer('div', 'RdYlGn', ntrgs);

sz = 10;
nbs = size(ZN,2);
nbs_c = ceil(sqrt(nbs));
nbs_r = round(nbs/nbs_c);

figure(2);

Ak = [alltrg - 22.5 alltrg + 22.5];
Ak(Ak < 0) = 360 + Ak(Ak < 0);
bnds = Ak;

for jj = 1:nbs
    subplot(nbs_c, nbs_r, jj);
    hold on;
    
    % plot scatter of each point
    for ii = 1:ntrgs
        ix = (targs == alltrg(ii));
        xx = T(ix);
        if mean(xx < 20) > 0.2 && mean(xx > 300) > 0.2
            xx(xx > 300) = xx(xx > 300) - 360;
        end
%         scatter(xx, ZN(ix,jj), sz, cmap(ii,:));    
    end
    
    % calculate mean/std for each group
    ys = [];
    vs = [];
    for ii = 1:ntrgs
        ysc = ZN(tools.isInRange(T, bnds(ii,:)),jj);
        ys = [ys mean(ysc)];
        vs = [vs 2*std(ysc)/sqrt(numel(ysc))];
    end
    
    % plot mean/std
    [~,iz] = sort(alltrg);
    clr = 0.5*ones(3,1);
    plot(alltrg(iz), ys(iz) - vs(iz), 'Color', clr);
    plot(alltrg(iz), ys(iz) + vs(iz), 'Color', clr);
    plot(alltrg(iz), ys(iz), '-', 'Color', clrA, 'LineWidth', 3);
    scatter(alltrg, ys, 10, 'k');
    
    xlim([-50 370]);
    ylim([-1.5 1.5]);
    
    plot(xlim, [0 0], '--', 'Color', [0.5 0.5 0.5]);
end

xlabel('\theta between cursor and target');
ylabel(['null activity in column ' num2str(jj) ' of null space']);
