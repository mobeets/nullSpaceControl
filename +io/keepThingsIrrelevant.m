function D = keepThingsIrrelevant(D, noKeepEmRelevant, cols, doReverse)
    if nargin < 2
        noKeepEmRelevant = false;
    end
    if nargin < 3
        cols = [];
    end
    if nargin < 4
        doReverse = false;
    end
    D = io.makeImeDefault(D);
    
    if doReverse
        B = D.blocks(1);
        D.blocks(1) = D.blocks(2);
        D.blocks(2) = B;
    end
    
    NB1 = D.blocks(1).fDecoder.NulM2;
    RB1 = D.blocks(1).fDecoder.RowM2;
    if noKeepEmRelevant
        Bs = RB1*RB1';
    else
        if ~isempty(cols)
            NB1 = NB1(:,cols); % to keep same # dims as in RB1 case
        end
        Bs = NB1*NB1';
    end
    D.blocks(1).latents = D.blocks(1).latents*Bs;
    D.blocks(2).latents = D.blocks(2).latents*Bs;
        
end
