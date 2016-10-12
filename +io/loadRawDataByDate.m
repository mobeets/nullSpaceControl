function D = loadRawDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    mnkNms = io.getMonkeys();
    for ii = 1:numel(mnkNms)
        [fs, dr] = getFolders(DATADIR, mnkNms{ii}, dtstr);
        if numel(fs) > 0
            break;
        end
    end
    
    if numel(fs) == 0
        error('Date not found.');
        return;
    elseif numel(fs) ~= 2
        error(['There should be exactly two files in ' dr]);
        % one for kalmanInitParams, and one for simpleData
        return;
    end
    load(fullfile(dr, fs{1}));
    load(fullfile(dr, fs{2}));

    D.datestr = dtstr;
    D.kalmanInitParams = kalmanInitParams;
    D.simpleData = simpleData;
%     D.params = io.setBlockStartTrials(D.datestr);
    D.params.IDEAL_SPEED = 175;
    D = everythingInItsRightPlace(D);
    D.trials = io.makeTrials(D);
    
end

function [fldrs, dr] = getFolders(datadir, mnkname, dtstr)
    dr = fullfile(datadir, mnkname, dtstr);
    fs0 = dir(fullfile(dr, '*.mat'));
    fldrs = {fs0(~[fs0.isdir]).name};
end

function D = everythingInItsRightPlace(D)
    if ~isfield(D.simpleData, 'targetAngles')
        D.simpleData.targetAngles = addAngles(D.simpleData.targetLocations);
    end
    if ~isfield(D.simpleData, 'nullDecoder')
        D.simpleData.nullDecoder = addNullDecoder(D);
    end
end

function dec = addNullDecoder(D)
    dec.FactorAnalysisParams = D.kalmanInitParams.FactorAnalysisParams;
    dec.FactorAnalysisParams.ph = dec.FactorAnalysisParams.Ph;
    dec.FactorAnalysisParams = rmfield(dec.FactorAnalysisParams, 'Ph');
    dec.spikeCountStd = D.kalmanInitParams.NormalizeSpikes.std;
    dec.spikeCountMean = D.kalmanInitParams.NormalizeSpikes.mean;
end

function angs = addAngles(locs)
    locs = locs(:,1:2);
    xm = median(unique(locs(:,1)));
    ym = median(unique(locs(:,2)));
    locs(:,1) = locs(:,1) - xm;
    locs(:,2) = locs(:,2) - ym;
    angs = tools.computeAngles(locs);
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
