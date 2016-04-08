
D = io.quickLoadByDate('20120601');
B = D.blocks(2);
Y = B.latents;
NB = B.fDecoder.NulM2;
% [u,s,v] = svd(Y*NB); NB = NB*v;
YN = Y*NB;

%%

Z = [];
gsz = [];
for ii = 1:5
    gsz = [gsz; B.thetaGrps];
%     Z = [Z; pred.condGaussFit(D, struct('byThetaGrps', true))];
    Z = [Z; pred.sameCloudFit(D)];
end
ZN = Z*NB;

%%

figure; set(gcf, 'color', 'w');
ncols = size(YN,2);

gs = B.thetaGrps;
grps = sort(unique(gs));
nrows = numel(grps);

errs = nan(numel(grps), size(YN,2));

C = 0;
for jj = 1:numel(grps)
    ix = grps(jj) == gs;
    YNc = YN(ix,:);
    
    ixz = grps(jj) == gsz;
    ZNc = ZN(ixz,:);
    
%     figure; set(gcf, 'color', 'w');
%     ncols = 3; nrows = 3;
%     C = 0;
    
    for ii = 1:size(YN,2)
        Yc = YNc(:,ii);
        Zc = ZNc(:,ii); Zc = Zc - min(Yc);
        Yc = Yc - min(Yc);
        C = C + 1;
 
%         subplot(ncols,nrows,2*ii-1); hold on;
        subplot(ncols,nrows,C); hold on;
        [c,b] = hist(Yc, 30);
%         bar(b, c./trapz(b,c), 'FaceColor', 'w', 'EdgeColor', 'k');
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        xlabel(['YN_' num2str(ii)]);

        % gauss estimation
        mu = mean(Yc); sig = std(Yc);
        xs = linspace(min(Yc), max(Yc));
        ys = normpdf(xs, mu, sig);
        plot(xs, ys, 'k-');

        % nonparam estimation
        h = 0.1;
        Phatfcn = ksdensity_nd(Yc, h);
        ysh = Phatfcn(xs');
        plot(xs, ysh, 'r-');
        
        % condnrm estimation
        muz = mean(Zc); sig = std(Zc);
        zs = normpdf(xs, muz, sig);
        plot(xs, zs, 'b-');
        
%         errs(jj,ii) = sqrt(sum((ysh - zs).^2));
        errs(jj,ii) = (muz - mu)^2;
    
        if ii == 1
            ylabel(['\theta = ' num2str(grps(jj))]);
        end

    end
end
plot.subtitle(D.datestr);

%%

figure; plot(mean(errs,2));
figure; imagesc(errs);
caxis([0 round(max(errs(:)))]);
colormap gray;
