function newTheta = reformatTheta(theta, theta_bin_centers)
% Input: theta{i}(j) is between -180 and 180
% Output: theta is between 0 and 360 except that values close to 360 are
% remapped to be less than 0

newTheta = cell(1,length(theta));
for blk = 1:length(theta)
    
    % Make all theta nonnegative
    t= theta{blk};
    t(t<0) = t(t<0)+360;
    
    
    lastPositiveTheta = mean(theta_bin_centers(end-1:end));
    t(t>lastPositiveTheta) = t(t>lastPositiveTheta)-360;
    
    newTheta{blk} = t;
    
end