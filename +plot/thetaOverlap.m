
optsR = struct('doNull', false, 'doRow', true, 'blockInd', 1, ...
    'mapInd', 2, 'grpName', 'thetaGrps');
angDst = @(a1,a2) abs(mod((a1-a2 + 180), 360) - 180);
angDstBlk = @(A1,A2) arrayfun(@(ii) angDst(A1(ii), A2(ii)), 1:size(A1,1));

dts = io.getAllowedDates();
for ii = 1:numel(dts)
    D = io.quickLoadByDate(dts{ii});
    thFcn = @(Y) arrayfun(@(ii) mod(tools.computeAngle(Y(ii,:)', [0; 1]), ...
        360), 1:size(Y,1));
%     thFcn = @(Y) mod(tools.computeAngle(mean(Y), [0; 1]), 360);
%     grpFcn = @(Y) score.thetaGroup(thFcn(Y), score.thetaCenters);
%     [vs, grps] = tools.valsByGrp(D, grpFcn, optsR);
    
    [vs, grps] = tools.valsByGrp(D, thFcn, optsR);
    cnts = score.thetaCenters;
    prcs = arrayfun(@(ii) mean(vs{ii} == cnts(ii)), 1:numel(cnts));
    
    B = D.blocks(1);
    for jj = 1:numel(grps)
        ix = grps(jj) == B.thetaGrps;
%         prcs(jj) = angDst(mean(B.thetas(ix)), mean(vs{jj}'));
        prcs(jj) = median(angDstBlk(B.thetas(ix), vs{jj}'));
%         prcs(jj) = mean((B.thetas(ix)' - vs{jj}).^2);
    end
%     prcs = prcs./max(prcs);
    
    subplot(2,3,ii); hold on;
    plot.singleValByGrp(prcs, grps);
    
    if ii == 1
        ylabel('median \theta_1 - \theta_2');
    else
        ylabel('');
    end
    ylim([0 180]);
%     ylabel('pct still in thetaGrp');
%     ylim([0 0.4]);
    title(D.datestr);
end
