function Ysamp = kde_samp(Y, Phatfcn, N)
% https://www.amstat.org/sections/srms/proceedings/y2008/Files/300875.pdf
    
    if nargin < 2
        Phatfcn = ksdensity_nd(Y);
    end
    
    M = Phatfcn(median(Y)); % max value
    bnds = [min(Y); max(Y)];
    bnds = [bnds [0; M]];    
    
    doneWarn = false;
    warnThresh = 0.01; % warn if only getting small pct of N each iter
    
    Ysamp = [];
    curN = N;    
    while size(Ysamp,1) < N
        if curN < 1000
            nreps = curN*1e3;
        else
            nreps = curN*1e2;
        end
        us = rand([size(bnds,2), nreps]);
        us = bsxfun(@plus, bnds(1,:), bsxfun(@times, diff(bnds), us'));
        ps = Phatfcn(us(:,1:end-1));
        
%         [curN size(us) size(ps)]

        ixKeep = us(:,end) <= ps;
        Ysampc = us(ixKeep,1:end-1);
        
        Ysamp = [Ysamp; Ysampc];
        curN = N - size(Ysamp,1);
        
%         [sum(ixKeep) size(Ysamp,1) N]
        if sum(ixKeep)/size(Ysampc,1) < warnThresh && ~doneWarn
            warning('kde_samp: increase nreps or change bandwith');
            doneWarn = true;
        end
    end
    Ysamp = Ysamp(1:N,:);
            
end
