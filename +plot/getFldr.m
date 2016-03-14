function fldr = getFldr(D, isMaster)
    if nargin < 2
        isMaster = false;
    end
    
    fldr = fullfile('plots', D.datestr);
    if ~isMaster
        dtstr = datestr(now, 'yyyy-mm-dd_HH-MM');
        fldr = fullfile(fldr, dtstr);
    else
        fldr = fullfile(fldr, 'master');
    end
    if ~exist(fldr, 'dir')
        mkdir(fldr);
    else
%         return;
        resp = input(['Folder "' fldr ...
            '" already exists. Continue (y/n)? '], 's');
        if isempty(resp) || strcmpi(resp(1), 'n')
            error('Red text of acquiescence.');
        end
    end
end
