
% dtstr = '20120601';
% dtstr = '20120525';
% dtstr = '20120709';
dtstr = '20131125';
% dtstr = '20131205';
% dtstr = '20120308';
params = io.setUnfilteredDefaults();
params = io.updateParams(params, io.setBlockStartTrials(dtstr), true);
opts = struct('doRotate', false);
D = io.quickLoadByDate(dtstr, params, opts);
fnm = io.pathToIme(dtstr);

%% fit velocity-IME model for intuitive and perturbation blocks

bs = [];
doLatents = true;

for bind = 1:2

    [U, Y, Xtarget] = imefit.prep(D.blocks(bind), doLatents);
    basedir = pwd;
    cd('velime_codepack_v1.0/');

    init_method = 'current_regression';
    verbose = true;
    PARALLEL = false;
    max_iters = 200; % I recommend 5,000 iterations for all real applications.
    TAU = 3;
    T_START = TAU + 2; % "whiskers" from each trial are well-defined beginning at timestep T_START
    TARGET_RADIUS = 20 + 18; % from Sadtler paper; positions in mm

    [estParams,LL] = velime_fit(U,Y,Xtarget,TAU,...
        'INIT_METHOD',init_method,...
        'verbose',verbose,...
        'max_iters',max_iters);
    D.ime(bind) = estParams;
    figure; plot(LL); title([D.datestr ' block ' num2str(bind) ' ime LL']);

    cd(basedir);
%     [mdlErrs, cErrs] = imefit.imeErrs(U, Y, Xtarget, estParams, ...
%         TARGET_RADIUS, T_START);
%     imefit.plotImeVsCursor(D, bind, mdlErrs, cErrs);
    D0 = io.quickLoadByDate(dtstr, io.setUnfilteredDefaults(), struct('doRotate', false));
    D0.ime(bind) = estParams;
    b = imefit.plotImeStats(D0, bind, doLatents);
    saveas(gcf, fullfile('plots', 'ime2', [dtstr '_' num2str(bind) '_lts.png']));
    bs = [bs b];
end

imefit.plotErrByBlock(bs(1), bs(2)); title(D.datestr);
saveas(gcf, fullfile('plots', 'ime2', [dtstr '_byTrial_lts.png']));

%% save

ime = D.ime;
if exist(fnm, 'file')
    resp = input('File exists. Continue? (y/n) ', 's');
    if resp(1) ~= 'y'
        error('Not saving...file already exists.');
    end
end
disp(['Saving ime model to ' fnm]);
save(fnm, 'ime');
