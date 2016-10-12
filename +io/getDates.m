function dts = getDates(asympsOnly, showRaw, mnkNms)
    if nargin < 1
        asympsOnly = true; % include only those that have asymptotes
    end
    if nargin < 2
        showRaw = false;
    end
    if nargin < 3
        mnkNms = io.getMonkeys();
    end

    if asympsOnly
        ss = io.shuffleStarts;
        dtnums = sort(ss(~isnan(ss(:,2)),1));
        dts = arrayfun(@num2str, dtnums, 'uni', 0);
        return;
    end

    DATADIR = getpref('factorSpace', 'data_directory');
    if showRaw
        dts = [];
        for ii = 1:numel(mnkNms)
            fnms = dir(fullfile(DATADIR, mnkNms{ii}));
            ix = [fnms.isdir] & ~strcmp({fnms.name}, '.') & ...
                ~strcmp({fnms.name}, '..');
            mnk = {fnms(ix).name};
            dts = [dts mnk];
        end
        dts = dts';
    else
        fnms = dir(fullfile(DATADIR, 'preprocessed'));
        dts = strrep({fnms(~[fnms.isdir]).name}, '.mat', '');
    end
end
