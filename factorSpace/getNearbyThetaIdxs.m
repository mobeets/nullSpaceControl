function nearbyIdxs = getNearbyThetaIdxs(theta, eligibleThetas, THETA_TOLERANCE)

assert(-180 <= theta && theta <= 180)
assert(all(eligibleThetas>=-180 & eligibleThetas<=180))
assert(THETA_TOLERANCE < 180);

nearbyIdxs = find((theta-THETA_TOLERANCE<= eligibleThetas) & (eligibleThetas <= theta+THETA_TOLERANCE));

% add edge cases
if theta + THETA_TOLERANCE > 180
    overflow = (theta + THETA_TOLERANCE) - 180;
    supplementalIdxs = find((eligibleThetas < -180+overflow));
    
    tooLarge = true;
end
if theta-THETA_TOLERANCE < -180
    if exist('tooLarge','var') && tooLarge
        error('theta cannot be so close to both -180 and 180 degrees')
    end
    overflow = -180 - (theta-THETA_TOLERANCE);
    supplementalIdxs = find((eligibleThetas > 180-overflow));
     
end

if exist('supplementalIdxs','var')
    nearbyIdxs = [nearbyIdxs supplementalIdxs];
end

assert(length(nearbyIdxs) == length(unique(nearbyIdxs)))