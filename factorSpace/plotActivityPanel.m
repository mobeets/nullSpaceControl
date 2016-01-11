function plottedVals = plotActivityPanel(latents, theta, basisVec, onlyShuffle)

DARKNESS = 0.8; % 0 is black, 1 is default coloring rgbcmy
LINEWIDTH = 4;
PLOT_WITH_DIRECTION = false; % if true, axes are score x angle; else vertical axis is block

% assert(all(size(basisVec)==[10 1])) % must be column vector in R^10
% assert(abs(norm(basisVec)-1)<1e-8) % must be unit vector
% 
% NUM_THETA_BINS = 8; assert(NUM_THETA_BINS>=8 && mod(log2(NUM_THETA_BINS),1)==0) % needs to divide evenly
% 
% 
% binwidth = 360/NUM_THETA_BINS;
% theta_bin_centers = 0:binwidth:360; % 8 bins
% 
% activityMean = nan(3,NUM_THETA_BINS+1); %first and last value will be identical
% activitySE = nan(3,NUM_THETA_BINS+1); % same for standard error
% 
% newTheta = reformatTheta(theta, theta_bin_centers);
% 
% for blk = 1:3
%     for bin = 1:NUM_THETA_BINS
%         
%         % Get theta boundaries (paying special attention to edge cases)
%         L = theta_bin_centers(bin)-binwidth/2;
%         U = theta_bin_centers(bin)+binwidth/2;
%         idxs = L < newTheta{blk} & newTheta{blk} <= U;
%         
%         % Subselect latents & get scores
%         currLatents = latents{blk}(:,idxs);
%         currScores = basisVec'*currLatents;
%         
%         % Compute mean on basisVec
%         activityMean(blk,bin) = mean(currScores);
%         activitySE(blk,bin) = std(currScores)/sqrt(length(currScores));
%         
%     end
% end

[activityMean, activitySE] = getMeanAndSE(latents,theta,basisVec);

numThetaBins = size(activityMean,2);

% Copy value at 360 to be value at 0
activityMean(:,end+1) = activityMean(:,1);
activitySE(:,end+1) = activitySE(:,1);

colors_direction = DARKNESS*eye(3);
colors_wo_direction = DARKNESS*colormap(hsv(numThetaBins));

hold on
if PLOT_WITH_DIRECTION
    
    for blk = 1:3
        errorbar(theta_bin_centers,activityMean(blk,:),activitySE(blk,:),'color',colors_direction(blk,:),'linewidth',LINEWIDTH)
    end
    axis([-10 370 -2.5 2.5])
    
    plottedVals = nan;
    
else
    
    if onlyShuffle
        block = [1 2];
    else
        block = [1 2 3];
    end
    
    for bin = 1:numThetaBins
        am = activityMean(:,bin)';
        plot(am(block),block,'color',colors_wo_direction(bin,:),'LineWidth',LINEWIDTH)
    end
    if onlyShuffle
        maxY = 3;
    else 
        maxY = 4;
    end
    AX = [-3.5 3.5 0.5 maxY-.5];
    axis(AX)
    
%     m = min(AX);
%     text(m-.5, 3, '1')
%     text(m-.5, 2, '2')
%     if ~onlyShuffle
%         text(m-.5, 1, '3')
%     end
    
    set(gca,'YDir','reverse')
    set(gca,'YTick',block)
    
    % --- TEMP SETTINGS FOR DAP TALK FIGURE MAKING ---
%     axis([-2 2 .5 maxY-.5])
    set(gca,'Fontsize',16)
	set(gca,'FontWeight','bold')
    set(gca,'Linewidth',3)
    
    set(gca,'YTick',[])
%     text(-3.7, 1, 'I','Fontsize',16,'FontWeight','bold','HorizontalAlignment','center')
%     text(-3.7, 2, 'P','Fontsize',16,'FontWeight','bold','HorizontalAlignment','center')
    
    plottedVals = activityMean(:,1:end-1);
        
end




