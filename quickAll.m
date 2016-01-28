
% dts = {'20120525', '20120601', '20131125', '20131205'};
% dts = {'20120525'};
dts = {'20120601', '20131125', '20131205'};
for dtstr = dts;
    if iscell(dtstr)
        dtstr = dtstr{1};
    end
    clear D;
    close all;
    quick;
end
