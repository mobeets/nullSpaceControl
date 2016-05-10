function [Z, rotThetas] = meanShiftFit(D, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('decoderNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'doSample', true, 'obeyBounds', true, 'boundsType', 'marginal', ...
        'grpName', 'thetaGrps', 'boundsThresh', inf);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    B1 = D.blocks(1);
    B2 = D.blocks(2);
    NB2 = B2.(opts.decoderNm).NulM2;
    RB2 = B2.(opts.decoderNm).RowM2;
    [nt, nn] = size(B2.latents);
    
    Y1 = B1.latents;
    YR1 = Y1*RB2;
    YN1 = Y1*NB2;
    YR2 = B2.latents*RB2;
    
    ths1 = B1.(opts.thetaNm);
    gs = B2.(opts.grpName);
    grps = sort(unique(gs));

    Zr = B2.latents*(RB2*RB2');
    Zsamp = nan(nt,nn);
    
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    opts.isOutOfBounds = pred.boundsFcn(Y1, opts.boundsType);
    d = 0;
    rotThetas = zeros(numel(grps), 1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        mu = mean(YR2(ix,:));
        
        offsets = -50:2.5:50;
        errs = nan(size(offsets));
        terrs = nan(size(errs));
        for jj = 1:numel(offsets)
            ixc = newGroup(ths1, offsets(jj)) == grps(ii);
            mu1 = mean(YR1(ixc,:));
            errs(jj) = norm(mu1 - mu);
            
            terrs(jj) = norm(mean(B2.latents(ix,:)*NB2) - mean(Y1(ixc,:)*NB2));
        end
        assert(all(newGroup(ths1,0) == B1.(opts.grpName)));
        
        [~,ixOffset] = min(errs);        
        ixc = newGroup(ths1, offsets(ixOffset)) == grps(ii);
        rotThetas(ii) = offsets(ixOffset);
        Ys = Y1(ixc,:);
        
%         [grps(ii) offsets(ixOffset) errs]
%         figure(1); hold on; plot(offsets, errs, 'Color', clrs(ii,:), 'LineWidth', 4);
%         figure(2); hold on; plot(offsets, terrs, 'Color', clrs(ii,:), 'LineWidth', 4);
%         figure(1); hold on; plot3(offsets, errs, terrs, '-o', 'Color', clrs(ii,:), 'LineWidth', 4);
%         plot3(offsets(ixOffset), errs(offsets == offsets(ixOffset)), terrs(offsets == offsets(ixOffset)), 'ko', 'LineWidth', 4);
%         hold on; bar(grps(ii), offsets(ixo), 'FaceColor', clrs(ii,:), ...
%             'EdgeColor', 'k');

        ts = 1:nt; ts = ts(ix);
        for jj = 1:numel(ts)
            opts.isOutOfBndsNul = pred.boundsFcnCond(YR2(ts(jj),:), ...
                YR1, YN1, opts.boundsThresh, opts.boundsType);
            [Zsamp(ts(jj),:), dc] = meanOrSample(Ys, opts, Zr(ts(jj),:), NB2);
            d = d + dc;
        end

    end
    if opts.obeyBounds && d > 0
        warning(['Corrected ' num2str(d) ' mean-shift samples to lie within bounds']);
    end
    Zn = Zsamp*(NB2*NB2');
    Z = Zr + Zn;

%     set(gcf, 'color', 'w')
%     axis vis3d;
%     xlabel('offset'); ylabel('row space err'); zlabel('null space err');
end

function gs = newGroup(ths, offset)
    ths = mod(ths + offset, 360);
    gs = score.thetaGroup(ths, score.thetaCenters(8));
end

function [z,d] = meanOrSample(zs, opts, zr, NB2)
    d = 0;
    c = 0;
    outOfBnds = @(z) opts.isOutOfBounds(z*(NB2*NB2') + zr) || ...
        opts.isOutOfBndsNul(z*NB2);
    if opts.doSample
        z = zs(randi(size(zs,1),1),:);
        while opts.obeyBounds && outOfBnds(z) && c < 10
            z = zs(randi(size(zs,1),1),:);
            c = c + 1;
        end
        if c > 1 && c < 10
            d = 1;
        end
    else
        z = nanmean(zs);
    end
end
