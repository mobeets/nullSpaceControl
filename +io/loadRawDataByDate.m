function D = loadRawDataByDate(dtstr)

    DATADIR = getpref('factorSpace', 'data_directory');
    
    dr1 = fullfile(DATADIR, 'Jeffy', dtstr);
    dr2 = fullfile(DATADIR, 'Lincoln', dtstr);
    fs1 = dir(dr1);
    fs1 = {fs1(~[fs1.isdir]).name};
    fs2 = dir(dr2);
    fs2 = {fs2(~[fs2.isdir]).name};
    if numel(fs1) + numel(fs2) == 0
        error('Date not found.');
        return;
    end
    if numel(fs1) > 0
        dr = dr1; fs = fs1;
    else
        dr = dr2; fs = fs2;
    end
    load(fullfile(dr, fs{1}));
    load(fullfile(dr, fs{2}));
        
%     if strcmp(dtstr,'20120525')
%         load([DATADIR '/Jeffy/20120525/20120525simpleData.mat']);
%         load([DATADIR '/Jeffy/20120525/kalmanInitParamsFA20120525(1).mat']);
%     elseif strcmp(dtstr, '20120601')
%         load([DATADIR '/Jeffy/20120601/20120601simpleData_combined.mat']);
%         load([DATADIR '/Jeffy/20120601/kalmanInitParamsFA20120601(2).mat']);
%     elseif strcmp(dtstr, '20131125')
%         load([DATADIR '/Lincoln/20131125/20131125simpleData.mat']);
%         load([DATADIR '/Lincoln/20131125/kalmanInitParamsFA20131125_11.mat']);
%     elseif strcmp(dtstr, '20131205')
%         load([DATADIR '/Lincoln/20131205/20131205simpleData.mat']);
%         load([DATADIR '/Lincoln/20131205/kalmanInitParamsFA20131205_11.mat']);
%     else
%         error('Date not supported yet')
%     end

    D.datestr = dtstr;
    D.kalmanInitParams = kalmanInitParams;
    D.simpleData = simpleData;
    
end
