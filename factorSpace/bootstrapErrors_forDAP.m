function bootstrapErrors_forDAP(predictions, theta, nullBasis)

B = 1000;

numHyp = length(predictions)-1;

[~, ~, ~, ~, realBinnedLatents] = getMeanAndSE(predictions(1).latents,theta,nullBasis);

% get binned latents
hypBinnedLatents = cell(1,numHyp);
for hyp = 1:numHyp
    [~, ~, ~, ~, hypBinnedLatents{hyp}] = getMeanAndSE(predictions(1+hyp).latents,theta,nullBasis);
end

hypErrors = nan(1,numHyp);
bootstrapErrors = nan(B, numHyp);

percentileLowError = nan(1,numHyp);
percentileHighError = nan(1,numHyp);

hypCov = nan(1,numHyp);
bootstrapCov = nan(B, numHyp); 

percentileLowCov = nan(1,numHyp);
percentileHighCov = nan(1,numHyp);

% realCov = computeCov(realBinnedLatents);

% for each hypothesis
for hyp = 1:numHyp
    
    % compute prediction error
    hypErrors(hyp) = computeError(realBinnedLatents, hypBinnedLatents{hyp});
    hypCov(hyp) = computeCovError(realBinnedLatents,hypBinnedLatents{hyp});
%     hypCov(hyp) = computeCov(hypBinnedLatents{hyp});
    
    % for B bootstrap samples
    for b = 1:B
        
        % draw bootstrap sample
        bootstrapSample = getBootstrapSample(hypBinnedLatents{hyp});
        
        % compute bootstrap error
        bootstrapErrors(b,hyp) = computeError(realBinnedLatents, bootstrapSample);
        
        bootstrapCov(b,hyp) = computeCovError(realBinnedLatents, bootstrapSample);
        
    end
    
    sortedBootstrapErrors = sort(bootstrapErrors(:,hyp),'ascend');
    
    percentileLowError(hyp) = sortedBootstrapErrors(floor(.025*B));
    percentileHighError(hyp) = sortedBootstrapErrors(ceil(.975*B));
    
    sortedBootstrapCov = sort(bootstrapCov(:,hyp), 'ascend');
    
    percentileLowCov(hyp) = sortedBootstrapCov(floor(.025*B));
    percentileHighCov(hyp) = sortedBootstrapCov(ceil(.975*B));
        
end


% plot errors with bootstrap uncertainties
figure; hold on
bh = bar(1:numHyp, hypErrors, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 3);
eh = errorbar(1:numHyp, hypErrors, hypErrors-percentileLowError, percentileHighError-hypErrors, 'k.', 'Linewidth', 3);
ylabel('Error of Means','Fontsize', 24)
set(gca,'YTick',0:5)
set(gca,'Fontsize',16)
set(gca,'XTick', [])
set(gca,'LineWidth',3)
set(gca,'XColor',[1 1 1])
axis([0 numHyp+1 0 5])
set(gca,'FontWeight','bold')

h = -.4;
th = text(1,h,{'Minimal ','Firing Rate '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(2) = text(2,h,{'Baseline ','Firing Rate '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(3) = text(3,h,{'Unconstrained ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(4) = text(4,h,{'Habitual ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(5) = text(5,h,{'Volitional ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
set(gcf,'Position',[680 650 893 448])

% % error('not working.. messes up formatting')
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/meanErrors.png','-dpng')
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/meanErrors.jpg','-djpeg')
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/meanErrors.pdf','-dpdf')
% % 
% % saveas(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/meanErrors.fig','fig')

% % Build up plots
% for hyp = 1:numHyp
%     figure; hold on
%     bh = bar(1:hyp, hypErrors(1:hyp), 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 3);
%     eh = errorbar(1:hyp, hypErrors(1:hyp), hypErrors(1:hyp)-percentileLowError(1:hyp), percentileHighError(1:hyp)-hypErrors(1:hyp), 'k.', 'Linewidth', 3);
%     set(gca,'YTick',0:5:15)
%     set(gca,'Fontsize',16)
%     set(gca,'XTick', [])
%     set(gca,'LineWidth',3)
%     axis([0 numHyp+1 0 15])
% end

figure; hold on
bh = bar(1:numHyp, hypCov, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 3);
% jah: the line below was commented out because of
%   error "Complex inputs not supported for YData"
% eh = errorbar(1:numHyp, hypCov, hypCov-percentileLowCov, percentileHighCov-hypCov, 'k.', 'Linewidth', 3);
plot([0 numHyp+1], [1 1], 'k-', 'linewidth', 3)
ylabel('Covariance Ratio','Fontsize',24)
set(gca,'YScale','log')
set(gca,'YTick',10.^(-4:2))
% set(gca,'YMinorTick','off')
set(gca,'Fontsize',16)
set(gca,'XTick', [])
set(gca,'LineWidth',3)
set(gca,'XColor',[1 1 1])
axis([0 numHyp+1 10^-1 10^1])
set(gca,'FontWeight','bold')

h1 = 10^.1;
h2 = 10^-.1;
th = text(1,h1,{'Minimal ','Firing Rate '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(2) = text(2,h1,{'Baseline ','Firing Rate '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(3) = text(3,h2,{'Unconstrained ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(4) = text(4,h2,{'Habitual ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
th(5) = text(5,h2,{'Volitional ','Control '},'HorizontalAlignment','center','Fontsize',16, 'FontWeight', 'bold');
set(gcf,'Position',[680 650 893 448])


% % error('not working.. messes up formatting') 
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/covErrors.png','-dpng')
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/covErrors.jpg','-djpeg')
% % print(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/covErrors.pdf','-dpdf')
% % 
% % saveas(gcf,'/Users/peterlund/Dropbox/DAP/paper/figs/covErrors.fig','fig')


% plot(0:numHyp+1, realCov*ones(1,numHyp+2), 'b--','Linewidth', 3)
% set(gca,'YScale','log')
% set(gca,'YTick',10.^(-40:10:10))
% set(gca,'Fontsize',16)
% set(gca,'XTick', [])
% set(gca,'LineWidth',3)
% ax = axis;
% axis([0 numHyp+1 ax(3:4)])

% % Build up plots
% for hyp = 1:numHyp
%     figure; hold on
%     bar(1:hyp, hypCov(1:hyp), 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 3);
%     errorbar(1:hyp, hypCov(1:hyp), hypCov(1:hyp)-percentileLowCov(1:hyp), percentileHighCov(1:hyp)-hypCov(1:hyp), 'k.', 'Linewidth', 3);
%     plot(0:numHyp+1, realCov*ones(1,numHyp+2), 'b--','Linewidth', 3)
%     set(gca,'YScale','log')
%     set(gca,'YTick',10.^(-40:10:10))
%     set(gca,'Fontsize',16)
%     set(gca,'XTick', [])
%     set(gca,'LineWidth',3)
%     axis(ax)
% end




function error = computeError(realBinnedLatents, hypBinnedLatents)

realMu = cellfun(@(x) mean(x,2), realBinnedLatents, 'UniformOutput', 0);
hypMu = cellfun(@(x) mean(x,2), hypBinnedLatents, 'UniformOutput', 0);

numCond = size(realMu,2);

error = 0;

for c = 1:numCond
    
    error = error + (1/numCond)*norm(realMu{2,c}-hypMu{2,c});%^2;
    
end

% function cv = computeCov(binnedLatents)
% 
% cv = 0;
% 
% numCond = size(binnedLatents,2);
% 
% for c = 1:numCond
%    
%     cv = cv + (1/numCond)*det(cov(binnedLatents{2,c}'));
%     
% end

function covError = computeCovError(realBinnedLatents, hypBinnedLatents)

covError = 0;

numCond = size(realBinnedLatents,2);

dim = size(realBinnedLatents{1,1},1);
assert(dim == 8)

for c = 1:numCond
   
%     covError = covError + (1/numCond)*det(cov(binnedLatents{2,c}'));
    num = det(cov(hypBinnedLatents{2,c}'));
    den = det(cov(realBinnedLatents{2,c}'));
    covError = covError + (1/numCond)*(num/den)^(1/dim);
    
end

function bootstrapSample = getBootstrapSample(binnedLatents)

[R, C] = size(binnedLatents);
bootstrapSample = cell(R, C);

for r = 1:R
    for c = 1:C
        
        T = size(binnedLatents{r,c},2);
        
        bootstrapIdxs = randi(T,1,T);
        
        bootstrapSample{r,c} = binnedLatents{r,c}(:,bootstrapIdxs);
        
    end
end