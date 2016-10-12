function dts = getDates(asympsOnly, showRaw)
    if nargin < 1
        asympsOnly = true; % include only those that have asymptotes
    end
    if nargin < 2
        showRaw = false;
    end
%     dts = {'20120525', '20120601', '20131125', '20131205'};

    if asympsOnly
        ss = io.shuffleStarts;
        dtnums = sort(ss(~isnan(ss(:,2)),1));
        dts = arrayfun(@num2str, dtnums, 'uni', 0);
        return;
    end

    DATADIR = getpref('factorSpace', 'data_directory');
    if showRaw
        fnms = dir(fullfile(DATADIR, 'Jeffy'));
        ix = [fnms.isdir] & ~strcmp({fnms.name}, '.') & ...
            ~strcmp({fnms.name}, '..');
        Jeffy = {fnms(ix).name};
        fnms = dir(fullfile(DATADIR, 'Lincoln'));
        ix = [fnms.isdir] & ~strcmp({fnms.name}, '.') & ...
            ~strcmp({fnms.name}, '..');
        Lincoln = {fnms(ix).name};
        dts = [Jeffy Lincoln];
    else
        fnms = dir(fullfile(DATADIR, 'preprocessed'));
        dts = strrep({fnms(~[fnms.isdir]).name}, '.mat', '');
    end
end
