function [F, E] = toDataHigh(dtstr)
% 
% F(ii) = 
% 
%            data: [6x30 double] % (num_latents x num_trials_in_cond)
%       condition: 'reach2'
%            type: 'state'
%     epochStarts: 1
%     epochColors: [0 1 0]
% 

    E = fitByDate(dtstr, [], {'habitual', 'cloud-hab', 'volitional-w-2FAs'});
    B = E.blocks(2);
    NB = B.fDecoder.NulM2;

    gs = B.thetaGrps;
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        
        f.data = (B.latents(ix,:)*NB)';
        f.condition = num2str(grps(ii));
        f.type = 'state';
        f.epochStarts = 1;
        f.epochColors = clrs(ii,:);
        F(ii) = f;
        
%         H = pred.getHyp(E, 'volitional-w-2FAs');
%         f.data = (H.latents(ix,:)*NB)';
%         f.condition = [num2str(grps(ii)) '-' H.name];
%         f.type = 'state';
%         f.epochStarts = 1;
%         f.epochColors = clrs(ii,:);
%         F(ii) = f;
        
        H = pred.getHyp(E, 'volitional-w-2FAs');
        f.data = (H.latents(ix,:)*NB)';
        f.condition = [num2str(grps(ii)) '-' H.name];
        f.type = 'state';
        f.epochStarts = 1;
        f.epochColors = clrs(ii,:);
        F(numel(grps)+ii) = f;
    end

end
