pDim = 2;
vDim = 2;
uDim = 25;

A = .5*eye(vDim);
B = randn(vDim,uDim);
b0 = randn(vDim,1);
TAU = 5;
dt = 1/30;
[M,M0] = velime_buildM(struct('A',A,'B',B,'b0',b0,'TAU',TAU,'dt',dt));

p1 = randn(pDim,1);
v0 = randn(vDim,1);
u = randn(uDim,TAU+1);
c = [p1;v0;u(:)];


% This is faster for large TAU/uDim
tic
x = M*c + M0;
toc

%This is faster for small TAU/uDim (i.e., large uDim)
tic
p = [p1 zeros(pDim,TAU)];
v = [A*v0+B*u(:,1) + b0 zeros(vDim,TAU)];
for i = 2:TAU+1
    p(:,i) = p(:,i-1) + v(:,i-1)*dt;
    v(:,i) = A*v(:,i-1) + B*u(:,i) + b0;
end
toc

% Maybe we should implement both and determine online which to use based on
% a speed test (way down the road).

xtrue = [p; v];
xtrue = xtrue(:);
[x - xtrue]