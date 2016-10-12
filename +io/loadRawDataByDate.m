function D = loadRawDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    mnkNm = '';
    mnkNms = io.getMonkeys();    
    for ii = 1:numel(mnkNms)
        [fs, dr] = getFolders(DATADIR, mnkNms{ii}, dtstr);
        if numel(fs) > 0
            mnkNm = mnkNms{ii};
            break;
        end
    end
    
    if numel(fs) == 0
        error('Date not found.');
        return;
    elseif strcmp(mnkNm, 'Nelson')
        if numel(fs) ~= 3
            error(['There should be exactly three files in ' dr]);
            return;
        end
    elseif numel(fs) ~= 2
        error(['There should be exactly two files in ' dr]);
        % one for kalmanInitParams, and one for simpleData
        return;
    end
    load(fullfile(dr, fs{1}));
    load(fullfile(dr, fs{2}));
    if strcmp(mnkNm, 'Nelson')
        tm = load(fullfile(dr, fs{3}));
        D.kalmanInitParamsPert = tm.kalmanInitParams;
    end

    D.datestr = dtstr;
    D.kalmanInitParams = kalmanInitParams;
    D.simpleData = simpleData;
%     D.params = io.setBlockStartTrials(D.datestr);
    D.params.IDEAL_SPEED = 175;
    if strcmp(mnkNm, 'Nelson')
        D = io.preprocessNelsonData(D);
    end
    D.trials = io.makeTrials(D);
    
end

function [fldrs, dr] = getFolders(datadir, mnkname, dtstr)
    dr = fullfile(datadir, mnkname, dtstr);
    fs0 = dir(fullfile(dr, '*.mat'));
    fldrs = {fs0(~[fs0.isdir]).name};
end

%%

% DATADIR = getpref('factorSpace', 'data_directory');
% mnkNm = 'Lincoln';
% basedir = fullfile(DATADIR, mnkNm);
% drs = dir(fullfile(basedir, '*simpleData*'));
% tmp = arrayfun(@(ii) strsplit(drs(ii).name, 'simple'), ...
%     1:numel(drs), 'uni', 0);
% dtc = cellfun(@(d) d{1}, tmp, 'uni', 0);
% for ii = 1:numel(dtc)
%     drnm = fullfile(basedir, dtc{ii})
%     mkdir(drnm);
% end
