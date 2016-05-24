function Z = uncContFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder', 'obeyBounds', true, ...
        'boundsType', 'marginal', 'boundsThresh', inf);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);    
    
    B1 = D.blocks(1);    
    isOutOfBounds = pred.boundsFcn(B1.latents, opts.boundsType);
    YR1 = B1.latents*RB2;
    YN1 = B1.latents*NB2;
    YR2 = B2.latents*RB2;
    YNN1 = B1.latents*(NB2*NB2');
    [nt1, ~] = size(B1.latents);

    Zr = B2.latents*(RB2*RB2');
%     Zn = nan(size(Zr));
% 
%     % trying to be quicker...
%     evf = @(fcn, val) fcn(val);
%     isOutBndsNul = @(t) pred.boundsFcnCond(YR2(t,:), YR1, YN1, ...
%         opts.boundsThresh);
%     isOutBnds = @(t1, t2) evf(isOutBndsNul(t2), YN1(t1,:)) || ...
%         isOutOfBounds(YNN1(t1,:) + Zr(t2,:));
%     ixGood = @(t) arrayfun(@(t1) ~isOutBnds(t1, t), 1:nt1);
%     ixGoodCounts = arrayfun(@(t) sum(ixGood(t)), 1:nt);

%     if opts.obeyBounds
%         for t = 1:nt
%             isOutBndsNul = pred.boundsFcnCond(YR2(t,:), ...
%                 YR1, YN1, opts.boundsThresh);
%             ixGood = ~arrayfun(@(ii) isOutBndsNul(YN1(ii,:)) || ...
%                 isOutOfBounds(YNN1(ii,:) + Zr(t,:)), 1:nt1);
%             YN1c = YNN1(ixGood,:);
%             Zn(t,:) = YN1c(randi(size(YN1c,1)),:);
%         end
%     else
%         ntB1 = size(B1.latents,1);
%         Zsamps = B1.latents(randi(ntB1, nt, 1),:);
%         Zn = Zsamps*(NB2*NB2');
%     end
    
    % sample Z uniformly from B1 for each time point
    ntB1 = size(B1.latents,1);
    Zsamps = B1.latents(randi(ntB1, nt, 1),:);
    Zn = Zsamps*(NB2*NB2');
    
    % correct to be within bounds defined by B1
    if opts.obeyBounds        
        c = 0;
        isOutBndsNul = @(t) pred.boundsFcnCond(YR2(t,:), ...
            YR1, YN1, opts.boundsThresh);
        evF = @(f, z) f(z); Znn = Zsamps*NB2;
        isOutBnds = arrayfun(@(t) isOutOfBounds(Zn(t,:)+Zr(t,:))...
            || evF(isOutBndsNul(t), Znn(t,:)), 1:nt);
        ntc = sum(isOutBnds);

        d = ntc;
        pctChange = 1; minPctChng = 0.005;
        while ntc > 0 && (pctChange > minPctChng || c < 20)
            Zsamps(isOutBnds,:) = B1.latents(randi(ntB1, ntc, 1),:);
            Zn = Zsamps*(NB2*NB2');
            
            if ~isinf(opts.boundsThresh)
                Znn = Zsamps*NB2;
                isOutBndsNul = @(t) pred.boundsFcnCond(YR2(t,:), ...
                    YR1, YN1, opts.boundsThresh);
                evF = @(f, z) f(z);
                isOutBnds = arrayfun(@(t) isOutOfBounds(Zn(t,:)+Zr(t,:))...
                    || evF(isOutBndsNul(t), Znn(t,:)), 1:nt);
            else % faster if no boundsThresh
                isOutBnds = arrayfun(@(t)isOutOfBounds(Zn(t,:)+Zr(t,:)),...
                    1:nt);
            end
            
            pctChange = (ntc - sum(isOutBnds))/ntc;
            ntc = sum(isOutBnds);
            c = c + 1;
        end        
        d = d - ntc; % number we were able to correct
    end
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ...
            ' unconstrained samples to lie within bounds']);
    end
        
    Z = Zr + Zn;
end
