function [latents, A, b, Ainv, binv] = convertRawSpikesToRawLatents_byDate(spikes,date)

data_directory = getpref('factorSpace', 'data_directory');

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

[latents, A, b, Ainv, binv] = convertRawSpikesToRawLatents(simpleData,spikes);