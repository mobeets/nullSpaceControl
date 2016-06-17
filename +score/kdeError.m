function scores = kdeError(Y, Yhs, kind)
% 
% Y = D.hyps(1).nullActivity.zNull;
% Yhs = cellfun(@(obj) obj.zNull, {D.hyps(2:end).nullActivity}, 'uni', 0);
% 
    if nargin < 3
        % fit kde to Y; evaluate prob. of each Yh in Yhs under that kde
        kind = '';
    end
    if strcmp(kind, 'all')
        % fit kdes to each of Y and Yh in Yhs, evaluate L2 norm of diff
        kind = ' all';
    end
    
%     [u,s,v] = svd(Y);
%     v = v(:,1:2);
%     Y = Y*v;
%     Yhs = cellfun(@(Yh) Yh*v, Yhs, 'uni', 0);
%     [~, ~, ~, ~, ~, ~, scores] = compareKde(Y, Yhs, true);
%     return;

    % save activity to .mat
    fnm = [datestr(datetime) '.mat'];
    fnm = regexprep(fnm, {':', '/', ' '}, {'_', '_', '_'});
    datfile = fullfile('data', 'latents', fnm);
    resfile = strrep(datfile, '.mat', '_res.mat');
    save(datfile, 'Y', 'Yhs');    
    
    % call python file to fit kdes and score
    PYTHONPATH = fullfile(getenv('HOME'), 'anaconda', 'bin', 'python');
    cmd = [PYTHONPATH ' pykde/score.py' kind ...
        ' --infile ' datfile ' --outfile ' resfile];
    warning(cmd);
    [status, results] = system(cmd);
    if status
        error(results);
    end
    res = load(resfile);
    scores = res.scores;

end
