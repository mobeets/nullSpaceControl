
% D = io.quickLoadByDate('20120709');
decNm = 'fImeDecoder';
grpNm = 'thetaImeGrps';

decNm = 'fDecoder';
grpNm = 'thetaGrps';

for ii = 1:2    
    NB = D.blocks(ii).(decNm).NulM2;
    RB = D.blocks(ii).(decNm).RowM2;
    
    B = D.blocks(2);
    Y = B.latents;
    gs = B.(grpNm);
    ix = ~isnan(gs); Y = Y(ix,:); gs = gs(ix,:);
    
    fcn = @(Y) median(sqrt(sum(Y.^2,2)));
    
    plot.init;
    vals = Y*NB;
    [vs, grps] = tools.singleValByGrp(vals, gs, fcn);
    plot.singleValByGrp(vs, grps, [], [], struct('LineMarkerStyle', 'r--'));
    vals = Y*RB;
    [vs, grps] = tools.singleValByGrp(vals, gs, fcn);
    plot.singleValByGrp(vs, grps, [], [], struct('LineMarkerStyle', 'b--'));
    vals = Y;
    [vs, grps] = tools.singleValByGrp(vals, gs, fcn);
    plot.singleValByGrp(vs, grps, [], [], struct());
    title([D.datestr ' Blk ' num2str(ii)]);
    [grps vs]
end

%%

% D = io.quickLoadByDate('20131125');

decNm = 'fImeDecoder';
grpNm = 'thetaImeGrps';

% decNm = 'fDecoder';
% grpNm = 'thetaGrps';

fcn = @(Y) sqrt(sum(Y.^2,2));
for ii = 1:2
    for jj = 1:2
        NB = D.blocks(ii).(decNm).NulM2;
        RB = D.blocks(ii).(decNm).RowM2;
        Y = D.blocks(jj).latents;
        gs = D.blocks(jj).(grpNm);
        ix = ~isnan(gs); Y = Y(ix,:); gs = gs(ix,:);
        
        v1 = fcn(Y*NB)./(fcn(Y*NB) + fcn(Y*RB));
        v2 = fcn(Y*NB)./fcn(Y);
        v3 = fcn(Y);
        nm = [D.datestr '-' num2str(ii) '-' num2str(jj)];
        [nm ': ' num2str([median(v1) median(v2) median(v3)])]
    end
end

%%

dts = io.getAllowedDates();
vs = [];
for jj = 1:numel(dts)
    D = io.quickLoadByDate(dts{jj});
    vc = [];
    for ii = 1:2
        B = D.blocks(ii);
        decNm = 'fDecoder';
        NB = B.(decNm).NulM2;
        RB = B.(decNm).RowM2;
        Y = B.latents;
        v1 = fcn(Y*NB)./(fcn(Y*NB) + fcn(Y*RB));

        decNm = 'fImeDecoder';
        NB = B.(decNm).NulM2;
        RB = B.(decNm).RowM2;
        Y = B.latents;
        v2 = fcn(Y*NB)./(fcn(Y*NB) + fcn(Y*RB));

        vc = [vc median(v1) median(v2)];
    end
    vs = [vs; vc];
end

%% 

plot.init;
xnms = {'B1', 'B2', 'B1ime', 'B2ime'};
for ii = 1:size(vs,1)
    subplot(2,3,ii); hold on; set(gca, 'FontSize', 18);
    bar(1:size(vs,2), 100*[vs(ii,1) vs(ii,3) vs(ii,2) vs(ii,4)], ...
        'FaceColor', [1 1 1], 'EdgeColor', [0 0 0]);
    ylim([0 100]);
    set(gca, 'XTick', 1:size(vs,2), 'XTickLabel', xnms, ...
        'XTickLabelRotation', 45);
    title(dts{ii});
end
ylabel('% in null space');

