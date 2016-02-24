
% decoder
t1 = D.blocks(1).fDecoder;
M0 = t1.M0; M1 = t1.M1; M2 = t1.M2;
M0 = [-0.1882 -0.4350]';
M1 = [0.3833 -0.0392; -0.0392 0.4798];
M2 = [-8.8094   -1.0547   -7.5893   -0.3099    3.5546   -1.1839   ...
        -1.8215    5.8684   13.9659  -0.6823; ...
       11.9495   -4.9226   -3.6940    9.5306    7.9062   -3.8578  ...
        10.1442   -3.2065   10.2660 0.9100];

% null space of decoder
nn = size(M2,2); % number of neural units
NM2 = null(M2); % basis for null space of M2
RM2 = rref(M2);
rowDim = size(RM2,1);
nullDim = size(NM2,2);

% init
nt = 100;
ps = nan(nt,2);
vs = nan(nt,2);
us = nan(nt,nn);
ps(1,:) = [0 0]; % cursor initially at origin
vs(1,:) = [0 0]; % cursor initially motionless
gain = 0.15; % how velocity change yields position change

% calculate neural activity so that cursor is motionless (offsets M0)
ex = (M2*RM2')\(-M0); % [0.045 0.04]';
ex = ex + [2 -1]';

% calculate cursor position using decoder and neural activity
for t = 2:nt
    % neural activity decomposed as null space + row space
    us(t,:) = NM2*randn(nullDim,1) + RM2'*ex;%randn(rowDim,1);
    
    % kinematics
    v = M2*us(t,:)' + M1*vs(t-1,:)' + M0;
%     v = M2*us(t,:)' + M0;
    vs(t,:) = v;
    ps(t,:) = ps(t-1,:) + gain.*vs(t-1,:);
end

% show cursor
close all;
figure; set(gcf, 'color', 'w'); box off; axis off;
lb = max(abs(ps(:))); lb = 1.05*lb;
for t = 1:nt
    scatter(ps(t,1), ps(t,2), 'o');
    xlim([-lb lb]);
    ylim([-lb lb]);
    pause(0.01);
end
