function [doSave, askedOnce] = checkSafeToSave(fldr, fnm, doSave, askedOnce)
% note: fnm should include file extension, e.g. "adsfsda.png"

    if ~doSave
        return;
    end
    if ~exist(fldr, 'dir')
        mkdir(fldr);
    end
    if exist(fnm, 'file') && ~askedOnce
        resp = input('Files exist. Continue? ', 's');
        askedOnce = true;
        if ~strcmpi(resp(1), 'y')
            warning('Okay, no saving then.');
            doSave = false;
        end
    end
end
