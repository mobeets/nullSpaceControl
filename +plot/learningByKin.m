function [lrn, Lmax, Lbest, Lraw] = learningByKin(dtstr, nms, Ya, nmsa)

%     ths = score.thetaCenters;
    if nargin < 3
        [Ya,~,~,nmsa] = plot.behaviorGrid(dtstr, {'thetaGrps'});
    end
    
    nkins = size(Ya{1},1);
    nflds = numel(nms);

    Lmax = cell(nkins, nflds);
    Lbest = cell(size(Lmax));
    Lraw = cell(size(Lmax));
    for jj = 1:nflds
        Y = Ya{strcmp(nmsa, nms{jj})};
        for ii = 1:nkins
            [Lmax{ii,jj}, Lbest{ii,jj}, Lraw{ii,jj}] = plot.learningOneKin(...
                Y{ii,1}, Y{ii,2});
        end
    end
    
    assert(numel(nms)==1);
    Lbest = cell2mat(Lbest);
    Lmax = cell2mat(Lmax);
    lrn = Lbest./Lmax;

end
