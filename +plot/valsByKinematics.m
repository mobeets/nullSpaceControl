function [vals, cnts] = valsByKinematics(D, xs, Y1, Y2, nbins, ...
    doNull, nbind, hopts)

    if nargin < 4
        Y2 = [];
    end
    if nargin < 5
        nbins = 8;
    end
    if nargin < 6
        doNull = true;
    end
    if nargin < 7
        nbind = bind;
    end
    if nargin < 8
        hopts = struct();
    end
    defopts = struct('decoderNm', 'fDecoder');
    hopts = tools.setDefaultOptsWhenNecessary(hopts, defopts);
        
    cnts = score.thetaCenters(nbins);
    
    % filter out nans
    ix = ~isnan(sum(Y1,2));
    if ~isempty(Y2)
        ix = ix & ~isnan(sum(Y2,2));
        Y2 = Y2(ix,:);
    end
    xs = xs(ix); Y1 = Y1(ix,:);
    M1f = score.avgByThetaGroup(xs, Y1, cnts);
    vals = arrayfun(@(ii) norm(M1f(ii,:)), 1:size(M1f,1));
    
    if ~doNull
        return;
    end
    
    % get null basis
    NB = D.blocks(nbind).(hopts.decoderNm).NulM2;    
    if true % doRotate
        [~,~,v] = svd(Y1*NB);
        NB = NB*v;
    end
    if ischar(doNull) && strcmpi(doNull, 'row')
        NB = D.blocks(nbind).(hopts.decoderNm).RowM2;
    end

    M1 = score.avgByThetaGroup(xs, Y1*NB, cnts);
    if ~isempty(Y2)
        M2 = score.avgByThetaGroup(xs, Y2*NB, cnts);
    else
        M2 = zeros(size(M1));
    end
    vals = arrayfun(@(ii) norm(M1(ii,:) - M2(ii,:)), 1:size(M1,1));
    
end
