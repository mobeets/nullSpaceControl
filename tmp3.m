
% conditional gaussian stuff

%%

d = 3;
mu = rand(d,1);
A = rand(d,d); S = A + A' + d*eye(d);
N = 100000;
X = mvnrnd(mu, S, N);

%%

% x1 | x2 = a
k = 2;
i1 = (k+1):numel(mu);
i2 = 1:k;

mu1 = mu(i1);
mu2 = mu(i2);
S11 = S(i1,i1);
S12 = S(i1,i2);
S22 = S(i2,i2);
S21 = S(i2,i1);

mubar = @(a) mu1 + S12*(S22\(a - mu2));
Sbar = @(a) S11 - S12*(S22\S21);

%% 

mue = norm(mean(X) - mu')
sige = norm(cov(X) - S)

%%

for ii = 2:3
    mdl{ii} = fitlm(X(:,1:ii-1), X(:,ii));
end

%%

figure;
N = 1000;
X = normrnd(0,4,[N 1]);
% X2 = zeros(N,N);
X2 = normrnd(0,4,[N N]);
err = nan(N,1);
for ii = 1:size(X2,2)
    err(ii) = norm(X - X2(:,ii));
end
hist(err, 20)
