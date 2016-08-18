function SHUFFLE_START = shuffleStarts()
% fit using behav.asymptotesAll, and corrected by eye when necessary
%   asymptotes fit for progress and trial_index, for all trials

%     START_WASHOUT = [
%         20120525 1600;
%         20120601 1330;
%         20131125 800;
%         20131205 800;
%     ];
    SHUFFLE_START = [
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
    ];
    
    
end
