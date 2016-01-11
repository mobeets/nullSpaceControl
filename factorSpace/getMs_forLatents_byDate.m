function [nullMs, shuffleMs] = getMs_forLatents_byDate(date)

data_directory = getpref('factorSpace', 'data_directory');

% load simpleData and kalmanInitParams for date
if strcmp(date,'20120525')
    load([data_directory '/Jeffy/20120525/20120525simpleData.mat']);
    load([data_directory '/Jeffy/20120525/kalmanInitParamsFA20120525(1).mat'])
elseif strcmp(date, '20120601')
    load([data_directory '/Jeffy/20120601/20120601simpleData_combined.mat']);
    load([data_directory '/Jeffy/20120601/kalmanInitParamsFA20120601(2).mat'])
elseif strcmp(date, '20131125')
    load([data_directory '/Lincoln/20131125/20131125simpleData.mat']);
    load([data_directory '/Lincoln/20131125/kalmanInitParamsFA20131125_11.mat'])
elseif strcmp(date, '20131205')
    load([data_directory '/Lincoln/20131205/20131205simpleData.mat']);
    load([data_directory '/Lincoln/20131205/kalmanInitParamsFA20131205_11.mat'])
else
    error('Date not supported yet')
end

% get Ms
[nullMs, shuffleMs] = getMs_forLatents(simpleData, kalmanInitParams);