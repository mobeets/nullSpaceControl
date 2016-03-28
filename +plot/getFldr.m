function fldr = getFldr(opts)
    if nargin < 1
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('isMaster', false, 'plotdir', 'plots', ...
        'doTimestampFolder', false, 'noVerifying', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
%     fldr = fullfile(opts.baseDir, D.datestr);
    fldr = opts.plotdir;
    if opts.doTimestampFolder
        if ~opts.isMaster
            dtstr = datestr(now, 'yyyy-mm-dd_HH-MM');
            fldr = fullfile(fldr, dtstr);
        else
            fldr = fullfile(fldr, 'master');
        end
    end
    if ~exist(fldr, 'dir')
        mkdir(fldr);
    elseif ~opts.noVerifying
%         return;
        resp = input(['Folder "' fldr ...
            '" already exists. Continue (y/n)? '], 's');
        if isempty(resp) || strcmpi(resp(1), 'n')
            error('Red text of acquiescence.');
        end
    end
end
