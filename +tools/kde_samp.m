function Ysamp = kde_samp(Y, Phatfcn, N)
% https://www.amstat.org/sections/srms/proceedings/y2008/Files/300875.pdf
    
    if nargin < 2
        Phatfcn = ksdensity_nd(Y);
    end
    
    M = Phatfcn(median(Y)); % max value
    bnds = [min(Y); max(Y)];
    bnds = [bnds [0; M]];
    
    if N < 1000
        nreps = N*1e3;
    else
        nreps = N*1e2;
    end
    
    Ysamp = [];
    while size(Ysamp,1) < N
        us = rand([size(bnds,2), nreps]);
        us = bsxfun(@plus, bnds(1,:), bsxfun(@times, diff(bnds), us'));
    %     us(end) <= Phatfcn(us(1:end-1))

        ixKeep = us(:,end) <= Phatfcn(us(:,1:end-1))';
        Ysampc = us(ixKeep,1:end-1);
        
        Ysamp = [Ysamp; Ysampc];        
    end
    Ysamp = Ysamp(1:N,:);
            
end
