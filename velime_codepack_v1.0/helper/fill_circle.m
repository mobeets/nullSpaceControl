function target_handle = fill_circle(center, radius, color, varargin)
% center is 1x2

center = reshape(center,1,2);

% dr = 1/500;
% r = 0:dr:2*pi;

N = 3000;
r = linspace(0,2*pi,N);
unit_circle = [cos(r)' sin(r)'];
target_pts = bsxfun(@plus, radius*unit_circle, center);

% Line target
if ~ishold(gca)
    cla
end
target_handle = fill(target_pts(:,1), target_pts(:,2),...
    color,'linestyle','none',varargin{:});