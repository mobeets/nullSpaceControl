function ns = findOptimalNulBasis(Y, nbs)
% search for columns of an orthogonal basis such that the norm of Y projected
%   onto each column is minimized, and each column is orthogonal to the
%   others
% 
% WARNING: ns will be tiny. i think maybe my approach is not sufficient
% 

    H = Y'*Y;
    ns = nan(nbs,size(H,1));

    Aeq = []; beq = [];
    options = optimset('Algorithm', 'interior-point-convex', ...
        'Display', 'off');
    for ii = 1:nbs
        if ii > 1 % enforce orthogonality to previous columns
            Aeq = ns(1:ii-1,:);
            beq = zeros(ii-1,1);
        end
        ns(ii,:) = quadprog(H, [], [], [], Aeq, beq, ...
            [],[],[], options);
    end
    ns = ns';

end
