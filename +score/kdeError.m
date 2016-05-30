function scores = kdeError(Y, Yhs)
% 
% Y = D.hyps(1).nullActivity.zNull;
% Yhs = cellfun(@(obj) obj.zNull, {D.hyps(2:end).nullActivity}, 'uni', 0);
% 

    % save activity to .mat
    fnm = [datestr(datetime) '.mat'];
    fnm = regexprep(fnm, {':', '/', ' '}, {'_', '_', '_'});
    outfile = fullfile('data', 'latents', fnm);
    resfile = strrep(outfile, '.mat', '_res.mat');
    save(outfile, 'Y', 'Yhs');
    
    % call python file to fit kdes and score
    PYTHONPATH = fullfile(getenv('HOME'), 'anaconda', 'bin', 'python');
    [status, results] = system([PYTHONPATH ' kde/score.py ' outfile ' ' ...
        resfile]);
    if status
        error(results);
    end
    res = load(resfile);
    scores = res.scores;

end
