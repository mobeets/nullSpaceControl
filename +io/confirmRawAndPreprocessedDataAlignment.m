function confirmRawAndPreprocessedDataAlignment(dtstr)

    D = io.loadRawDataByDate(dtstr);
    D.params = io.setParams(D);
    D.trials = io.makeTrials(D);
    E = io.quickLoadByDate(dtstr);

    Dt = D.trials;
    Et = E.trials;
    Dfns = fieldnames(Dt);
    Efns = fieldnames(Et);
    fns = intersect(Dfns, Efns);
    fnsD = setdiff(Dfns, Efns);
    fnsE = setdiff(Efns, Dfns);

	noError = true;
    for ii = 1:numel(fns)
        fn = fns{ii};
        d = Dt.(fn);
        e = Et.(fn);
        ix = ~any(isnan(d),2);
        nrmdf = norm(d(ix,:)-e(ix,:));
        if nrmdf > 1e-10
            noError = false;
            disp([fn ': ' num2str(nrmdf)]);
        end
    end
    if noError
        disp('All shared fields are basically identical.');
    end
    if ~isempty(fnsD)
        disp('Fields in raw but not in preprocessed:');
        disp(fnsD);
    end
    if ~isempty(fnsE)
        disp('Fields in preprocessed but not in raw:');
        disp(fnsE);
    end

end
