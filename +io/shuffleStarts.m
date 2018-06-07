function SHUFFLE_BOUNDS = shuffleStarts(minNumTrials)
% fit using behav.asymptotesAll, and corrected by eye when necessary
%   asymptotes fit for progress and trial_index, for all trials

%     START_WASHOUT = [
%         20120525 1600;
%         20120601 1330;
%         20131125 800;
%         20131205 800;
%     ];
    if nargin < 1
        minNumTrials = 100;
    end
    DATADIR = getpref('factorSpace', 'data_directory');
    fnm = fullfile(DATADIR, 'sessions', 'goodTrials_trialLength.mat');
    if exist(fnm, 'file') % set in file
        d = load(fnm);
        SHUFFLE_BOUNDS = d.Trs;
        ixGood = SHUFFLE_BOUNDS(:,3) - SHUFFLE_BOUNDS(:,2) >= minNumTrials;
        SHUFFLE_BOUNDS(ixGood,4) = 1;
        % set to nan any rows where last col == 0
        SHUFFLE_BOUNDS(SHUFFLE_BOUNDS(:,4) == 0,[2 3]) = nan;
        % skip rows with nans in data col
        SHUFFLE_BOUNDS = SHUFFLE_BOUNDS(~isnan(SHUFFLE_BOUNDS(:,1)),:);
    else % manually set
        error('Could not find goodTrials');
        SHUFFLE_BOUNDS = [
            20120303 nan; % no session asymptote
            20120308 668;
            20120319 768;
            20120327 453;
            20120331 700; % 897; % manual correction based on plot
            20120525 658;
            20120601 419;
            20120709 709;
            20131125 545;
            20131205 405;
            20131211 nan; % no session asymptote
            20131212 380; % 451; % manual correction based on plot
            20131218 486;
            20120302 nan;
            20120305 545;
            20120306 561;
            20120307 nan; % no session asymptote
            20120309 nan; % no session asymptote
            20120321 nan; % no session asymptote
            20120323 712;
            20120329 700; % manual avg of trial_index and progress
            20120403 nan; % no session asymptote
            20120514 nan; % no session asymptote by eye
            20120516 800; % manual correction based on plot
            20120518 nan; % no session asymptote by eye
            20120521 850; % manual correction based on plot
            20120523 717;
            20120528 553;
            20120530 800; % manual correction based on plot
            20120628 nan; % no session asymptote by eye
            20120630 747;
            20120703 500;
            20130527 nan; % no session asymptote
            20130528 nan; % too few Block 2 trials
            20130612 nan; % no session asymptote by eye
            20130614 nan; % too few Block 2 trials
            20130619 nan; % too few Block 2 trials
            20131124 nan; % too few Block 2 trials
            20131204 nan; % no session asymptote by eye
            20131208 nan; % no session asymptote by eye
            20131214 nan; % no session asymptote by eye
            20131215 nan; % too few Block 2 trials
            20160329 400; % manual correction based on plot
            20160402 nan; % 280 - but not enough Blk1 trials so setting nan
            20160404 nan; % not sure what's going on here...bimodal trial_lengths
            20160405 nan; % 360 - but not enough Blk1 trials so setting nan
            20160714 350; % manual correction based on plot
            20160722 nan; % no session asymptote by eye
            20160726 500;
            20160727 320;
            20160728 nan; % no session asymptote by eye
            20160810 380;
            20160812 nan; % not enough trials to fit asymptote
            20160814 250;
        ];
    end
    
    % add missing dates and give them nan
    dtnums = cellfun(@str2num, io.getDates(false, true));
    dtsMissing = dtnums(~ismember(dtnums, SHUFFLE_BOUNDS(:,1)));
    nd = size(SHUFFLE_BOUNDS,2)-1;
    tmp = [dtsMissing nan(numel(dtsMissing),nd)];
    if ~isempty(tmp)
        SHUFFLE_BOUNDS = [SHUFFLE_BOUNDS; tmp];
    end
    
%     SHUFFLE_BOUNDS(SHUFFLE_BOUNDS(:,1) == 20131212, 2:4) = [418 575 1];
%     SHUFFLE_BOUNDS(SHUFFLE_BOUNDS(:,1) == 20130528, 2:4) = [330 457 1];
        
end
