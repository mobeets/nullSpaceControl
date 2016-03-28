function [F, D] = toDataHigh(dtstr)
% 
% F(ii) = 
% 
%            data: [6x30 double] % (num_latents x num_trials_in_cond)
%       condition: 'reach2'
%            type: 'state'
%     epochStarts: 1
%     epochColors: [0 1 0]
% 

    nms = {'habitual', 'cloud-hab'};%, 'volitional-w-2FAs'};
    
    hypopts = struct('decoderNm', 'fDecoder');
    D = fitByDate(dtstr, [], nms, [], hypopts);
    B = D.blocks(2);
    NBB = B.fDecoder.NulM2;
    
    hypopts = struct('decoderNm', 'fImeDecoder');
    D = fitByDate(dtstr, [], nms, [], hypopts);
    A = D.blocks(2);
    NBA = A.fImeDecoder.NulM2;

    gs = B.thetaGrps;
    grps = sort(unique(gs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        
        f.data = (B.latents(ix,:)*NBB)';
        f.condition = num2str(grps(ii));
        f.type = 'state';
        f.epochStarts = 1;
        f.epochColors = clrs(ii,:);
        F(ii) = f;
        
        f.data = (A.latents(ix,:)*NBA)';
        f.condition = [num2str(grps(ii)) '-ime'];
        f.type = 'state';
        f.epochStarts = 1;
        f.epochColors = clrs(ii,:);
        F(numel(grps)+ii) = f;

        
%         H = pred.getHyp(E, 'volitional-w-2FAs');
%         f.data = (H.latents(ix,:)*NB)';
%         f.condition = [num2str(grps(ii)) '-' H.name];
%         f.type = 'state';
%         f.epochStarts = 1;
%         f.epochColors = clrs(ii,:);
%         F(ii) = f;
        
%         H = pred.getHyp(E, 'volitional-w-2FAs');
%         f.data = (H.latents(ix,:)*NB)';
%         f.condition = [num2str(grps(ii)) '-' H.name];
%         f.type = 'state';
%         f.epochStarts = 1;
%         f.epochColors = clrs(ii,:);
%         F(numel(grps)+ii) = f;
    end

end
