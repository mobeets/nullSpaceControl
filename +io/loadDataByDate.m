function d = loadDataByDate(datestr)

DATADIR = getpref('factorSpace', 'data_directory');

if strcmp(datestr,'20120525')
    load([DATADIR '/Jeffy/20120525/20120525simpleData.mat']);
    load([DATADIR '/Jeffy/20120525/kalmanInitParamsFA20120525(1).mat']);
elseif strcmp(datestr, '20120601')
    load([DATADIR '/Jeffy/20120601/20120601simpleData_combined.mat']);
    load([DATADIR '/Jeffy/20120601/kalmanInitParamsFA20120601(2).mat']);
elseif strcmp(datestr, '20131125')
    load([DATADIR '/Lincoln/20131125/20131125simpleData.mat']);
    load([DATADIR '/Lincoln/20131125/kalmanInitParamsFA20131125_11.mat']);
elseif strcmp(datestr, '20131205')
    load([DATADIR '/Lincoln/20131205/20131205simpleData.mat']);
    load([DATADIR '/Lincoln/20131205/kalmanInitParamsFA20131205_11.mat']);
else
    error('Date not supported yet')
end

d.datestr = datestr;
d.kalmanInitParams = kalmanInitParams;
d.simpleData = simpleData;

end
