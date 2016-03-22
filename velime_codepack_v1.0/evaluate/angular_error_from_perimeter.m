function [angles, theta, phi, p] = angular_error_from_perimeter(x_t_t, x_tp1_t, target_center, radius)
% [angles, theta, phi, p] = angular_error_from_perimeter(x_t_t, x_tp1_t, target_center, radius)
%
% INPUTS:
% x_t_t and x_tp1_t are DxN, N = number of time points, D = internal state
% dimensionality.  Only position elements (1:2,:) are looked at.
%
% target_center is 2x1, radius is 1x1
%
% OUTPUTS: 
% angles is Nx1 signed angular errors from the target perimeter, ie the
% minimal angular rotation of the aiming direction such that rotating
% (x_tp1_t - x_t_t) about x_t_t would intersect with a point, p, on the
% target perimeter
%
% OPTIONAL OUTPUTS:
% p is the perimeter point described above
% theta is the angular error between the aiming direction and (target_center - x_t_t)
% phi is the max angle between (target_center-x_t_t) and a perimeter point
%
% Fixed bug that makes 180 degree errors become 0: 6/27/2104

% *************************************************************************
[D,N] = size(x_t_t);
[D2,N2] = size(x_tp1_t);

if N~=N2 || D~=D2 || numel(target_center)~=2 || size(target_center,1)~=2 || numel(radius)~=1
    error('Inputs are not formatted correctly');
end

pos_idx = [1 2];

v1 = bsxfun(@minus, target_center, x_t_t(pos_idx,:));
v2 = x_tp1_t(pos_idx,:) - x_t_t(pos_idx,:);
v1_dot_v2 = dot(v1,v2);
% This is the sign of the zero-padded cross product:
% v1_cross_v2 = cross([v1;zeros(1,N)],[v2;zeros(1,N)]);
error_is_counterclockwise = sign(v1(1,:).*v2(2,:) - v1(2,:).*v2(1,:));
length_v1 = sqrt(sum(v1.^2,1));
length_v2 = sqrt(sum(v2.^2,1));

% Find the angle between v1 and v2
cos_theta = v1_dot_v2./(length_v1.*length_v2);
theta = acosd(cos_theta);
theta(error_is_counterclockwise==-1) = -theta(error_is_counterclockwise==-1);

% Find the largest angle between v1 and v3,
% where v1 is x_t_t to target_center, and
% v3 is x_t_t to a point on the circle perimeter
phi = asind(radius./length_v1) .* sign(theta);
phi(length_v1<radius) = 180;

radius_sq = radius^2;

% theta(n) and phi(n) must be the same sign.
idx_zero = abs(theta)<abs(phi); % aiming direction would bring cursor to target

angles = nan(1,N);
angles(idx_zero) = 0;
angles(~idx_zero) = theta(~idx_zero)-phi(~idx_zero);

if nargout==4
    p = nan(2,N);
    % distance from x_t_t to target
    l = sqrt(length_v1.^2-radius_sq);
    for n=1:N
        u = rotation_matrix(-angles(n))*(x_tp1_t-x_t_t)/norm(x_tp1_t-x_t_t);
        if idx_zero(n)
            method = 'fast';
            switch method
                case 'fast'
                    % WHY DOES THIS NOT WORK??!!
                    unit_v2 = v2(:,n)/length_v2(n);
                    C = x_t_t - target_center;
                    a = unit_v2'*unit_v2; % = 1
                    b = 2*unit_v2'*C;
                    c = C'*C - radius_sq;
                    determinant = b^2 - 4*a*c;
                    l_1 = (-b+sqrt(determinant))/(2*a);
                    l_2 = (-b-sqrt(determinant))/(2*a);
                    l(n) = min(l_1,l_2);
                     % a*l^2 + b*l + c should be zero
                case 'cvx'
                    disp('Using cvx to solve something that should be trivial--figure this out for a huge speedup');
                    cvx_quiet(true)
                    cvx_begin
                    variable l
                    minimize l
                    norm(x_t_t + l*u - target_center) < radius
                    cvx_end
            end
        end
        p(:,n) = x_t_t + l(n)*u;
    end
end

% TEST:
% error should be signed.
% theta(n) and phi(n) must be the same sign.