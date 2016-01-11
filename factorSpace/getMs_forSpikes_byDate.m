function [nullMs, shuffleMs] = getMs_forSpikes_byDate(date)

data_directory = getpref('factorSpace', 'data_directory');

% load simpleData and kalmanInitParams for date
if strcmp(date,'20120525')
    load([data_directory '/Jeffy/20120525/20120525simpleData.mat']);
elseif strcmp(date, '20120601')
    load([data_directory '/Jeffy/20120601/20120601simpleData_combined.mat']);
elseif strcmp(date, '20131125')
    load([data_directory '/Lincoln/20131125/20131125simpleData.mat']);
elseif strcmp(date, '20131205')
    load([data_directory '/Lincoln/20131205/20131205simpleData.mat']);
else
    error('Date not supported yet')
end

assert(length(simpleData.shuffles)==1)
nullMs = simpleData.nullDecoder.rawSpikes;
shuffleMs = simpleData.shuffles.rawSpikes;
