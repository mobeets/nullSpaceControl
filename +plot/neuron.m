
M2 = D.simpleData.nullDecoder.rawSpikes.M2;

ix0 = D.simpleData.targetAngles == 270;
ix = false(size(D.simpleData.spikeBins));
ix(D.simpleData.washoutIndices) = true;
ix(D.simpleData.nullIndices) = true;
ix = ix & ix0;
sps = cell2mat(D.simpleData.spikeBins(ix));
mus = D.simpleData.nullDecoder.spikeCountMean;

%%

yind = 49;
Y = sps(:,yind);
ymx = max(Y);
bins = 0:ymx;
N = histc(Y, bins);

m2 = M2(:,yind);


close all;
figure; set(gcf, 'color', 'w');
subplot(1,2,1);
hold on; set(gca, 'FontSize', 14); box off;
bar(bins, N, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 1);
plot([mus(yind) mus(yind)], [0 1.1*max(N)], '-r', 'LineWidth', 3);

subplot(1,2,2);
hold on; set(gca, 'FontSize', 14); box off;
ws = N./sum(N);
wbins = linspace(0, max(ws), 8);
clrs = cbrewer('seq', 'Reds', numel(wbins));
for ii = 1:numel(bins)
    [~,cind] = min((wbins - ws(ii)).^2);
    scatter(bins(ii)*m2(1), bins(ii)*m2(2), 120, clrs(cind,:), 'o', 'filled');
end
xlabel('v_x');
ylabel('v_y');

%%

vxind = -55:60;
vyind = -75:15;
[ix,iy] = meshgrid(vxind, vyind);
V = zeros(numel(vxind), numel(vyind));

xmx = -100; ymx = -100;
xmn = 100; ymn = 100;
for yind = 1:size(sps,2)
    Y = sps(:,yind);
    ymx = max(Y);D
    bins = 0:ymx;
    N = histc(Y, bins);
    ws = N./sum(N);
    m2 = M2(:,yind);    
    vx = bins*m2(1);
    vy = bins*m2(2);    
    for jj = 1:numel(bins)
        ix0 = ix == round(vx(jj));
        iy0 = iy == round(vy(jj));
        if vx(jj) > xmx
            xmx = vx(jj);
        end
        if vy(jj) > ymx
            ymx = vy(jj);
        end
        if vx(jj) < xmn
            xmn = vx(jj);
        end
        if vy(jj) < ymn
            ymn = vy(jj);
        end
        V(ix0 & iy0) = V(ix0 & iy0) + ws(jj);
    end
%     vx = ws.*vx';
%     vy = ws.*vy';
end
figure; imagesc(vxind, vyind, V);

%%

tlocs = sort(unique(D.simpleData.targetAngles));
for ii = 1:numel(tlocs)
    
    M2 = D.simpleData.nullDecoder.rawSpikes.M2;
%     M2 = D.simpleData.shuffles.rawSpikes.M2;

    ix0 = D.simpleData.targetAngles == tlocs(ii);
    ix = true(size(D.simpleData.spikeBins));
    ix(D.simpleData.washoutIndices) = false;
    ix(D.simpleData.nullIndices) = false;
    ix = ~ix;
    ix = ix & ix0;
    sps = cell2mat(D.simpleData.spikeBins(ix));
    mus = D.simpleData.nullDecoder.spikeCountMean;

    nboots = 1e5;
    inds = randi(size(sps,1), nboots, 1);
    spsc = sps(inds,:);
    vs = spsc*M2';
    figure;
    % hist3(vs, [20 20]);
    hist3(vs, 'Edges', {linspace(-200, 200, 20), linspace(-200, 200, 20)});

    xlabel('v_x'); ylabel('v_y');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    title(tlocs(ii));
end
