
G = x*y';
L = size(G,1);
norx = sum(x.*x,2);
nory = sum(y.*y,2);
Kxy = (-2*G + repmat(norx,[1,length(nory)]) +  repmat(nory',[length(norx),1]))';
mdist = median(Kxy(Kxy~=0));
sigma = sqrt(mdist/2);

%% example Y and Yhs

n = 600;
p = 3;
k = 3;
reps = 2;
Y = rand(n,p);
Yhs = cell(k,reps);
for jj = 1:reps
    for ii = 1:k
        Yhs{ii,jj} = rand(n,p);
    end
end

outfile = fullfile('kde', 'example2.mat');
save(outfile, 'Y', 'Yhs');
PYTHONPATH = fullfile(getenv('HOME'), 'anaconda', 'bin', 'python');
[status, result] = system([PYTHONPATH ' kde/score.py ' outfile]);
result = eval(result)

%% evaluate execution time as a function of hypothesis size

nanfcn = @(Y) Y(~isnan(sum(Y,2)),:);
nboots = 5;
n = 2000;
% randind = @(n, n1) randi(n, [n1 1]);
hinds = 2:numel(D.hyps);
Hs = D.hyps(hinds);

% scs = nan(numel(ns), 2);
scs = nan(nboots, numel(Hs)+1);
for ii = 1:nboots
    Y = D.hyps(1).nullActivity.zNull;
    
    inds = randperm(size(Y,1));
    ixTrain = inds(1:n);
    ixTest = inds(n+1:n+n);    
    
    Yhs = cell(numel(Hs)+1,1);
    Yhs{1} = Y(ixTest,:);    
    for jj = 1:numel(Hs)
        Yhs{jj+1} = Hs(jj).nullActivity.zNull(ixTrain,:);
    end
    Y = Y(ixTrain,:);
    
%     inds = randind(size(Y,1), n);
%     Y = nanfcn(Y(inds,:));
%     Yhs = cellfun(@(obj) nanfcn(obj.zNull(inds,:)), ...
%         {D.hyps(hinds).nullActivity}, 'uni', 0);
%     Yhs = Yhs(~cellfun(@isempty, Yhs));    
%     tic;
    scs(ii,:) = score.kdeError(Y, Yhs)
%     t = toc;
%     scs(ii,:) = [n t]    
end
scs = -scs;
% plot.init; plot(scs(:,1), scs(:,2), 'ko');

%% plot bar results

mu = mean(scs,1);
se = 2*std(scs,[],1)/sqrt(size(scs,2));
plot.init;
bar(1:numel(mu), mu, 'FaceColor', 'w');
for ii = 1:numel(se)
    line([ii ii], [mu(ii)-se(ii); mu(ii)+se(ii)], 'Color', 'k');
end
ylim([floor(min(scs(:))) ceil(max(scs(:)))])

%% bootstrap fits, evaluate each on true kde

Y = D.hyps(1).nullActivity.zNull;
ixTrain = randi(2, size(Y,1), 1) > 1;
Y0 = Y(~ixTrain,:);
Y = Y(ixTrain,:);
NB = D.blocks(2).fDecoder.NulM2;
nboots = 5;
Yhs = cell(2,nboots);
for ii = 1:nboots
    inds = randi(size(Y0,1), size(Y0,1), 1);
    Yhs{1,ii} = Y0(inds,:);
    Yhs{2,ii} = pred.sameCloudFit(D)*NB;
end

minn = min([size(Yhs{2,1},1), sum(ixTrain) sum(~ixTrain)])
for ii = 1:nboots
    Yhs{1,ii} = Yhs{1,ii}(1:minn,:);
    Yhs{2,ii} = Yhs{2,ii}(1:minn,:);
end
Y = Y(1:minn,:);

sc = score.kdeError(Y, Yhs)

%%

Hs = D.hyps(2:end);
nhyps = numel(Hs);
ngrps = numel(D.hyps(1).nullActivity.zNullBin);
scs = nan(ngrps, nhyps);
for ii = 1:ngrps
    Y = D.hyps(1).nullActivity.zNullBin{ii};
    Yhs = cell(nhyps,1);
    for jj = 1:nhyps
        Yhs{jj} = D.hyps(jj).nullActivity.zNullBin{ii};
    end
    scs(ii,:) = score.kdeError(Y, Yhs)
end
 
%%

grps = D.hyps(1).nullActivity.grps;
plot.init;
for ii = 1:size(scs,2)
    plot(grps, scs(:,ii), 'LineWidth', 3);
end
legend({Hs.name});
legend boxoff;
