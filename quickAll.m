
dts = {'20120525', '20120601', '20131125', '20131205'};
% dts = {'20120525'};
% dts = {'20120601', '20131125', '20131205'};
for dt = dts;
    if iscell(dt)
        dtstr = dt{1};
    else
        dtstr = dt;
    end
    disp('------');
    disp(dtstr);
    disp('------');
    clear D;
    close all;
    quick;
end
