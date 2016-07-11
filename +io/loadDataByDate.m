function D = loadDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'preprocessed', [dtstr '.mat']);    
    if ~exist(fnm, 'file')
        warning(['Preprocessed data for ' dtstr ' does not exist. Loading raw.']);
        D = io.loadRawDataByDate(dtstr);
    else
        data = load(fnm);
        D = data.D;
    end
    
    D.params = io.setFilterDefaults(D.datestr);
    D.trials = addExtraFields(D.trials);
end

function trials = addExtraFields(trials)
    trials.angErrorAbs = abs(trials.angError);
    trials.thetaActualGrps = score.thetaGroup(trials.thetaActuals, ...
        score.thetaCenters(8));
    trials.thetaActualGrps16 = score.thetaGroup(trials.thetaActuals, ...
        score.thetaCenters(16));
    trials.thetaGrps16 = score.thetaGroup(trials.thetas, ...
        score.thetaCenters(16));
    trials.progressOrth = addProgressOrth(trials);
end

function progOrth = addProgressOrth(trials)

    progOrth = nan(size(trials.progress));
    for t = 1:numel(trials.progress)
        vec2trg = trials.vec2target(t,:);
        vec2trgOrth(1) = vec2trg(2);
        vec2trgOrth(2) = -vec2trg(1);
        movVec = trials.movementVector(t,:);
        progOrth(t) = -(movVec*vec2trgOrth'/norm(vec2trg));
    end
end
