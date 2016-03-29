function [lrn, Lmax, Lbest, Lraw] = learningByKin(dtstr, nms, Ya, nmsa, sgns)
%     ths = score.thetaCenters;
    if nargin < 3
        Ya = [];
    end    
    if nargin < 5
        sgns = ones(size(nms));
    end
    if isempty(Ya)
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
    if nflds > 1
        lrn = nan(nkins,1);
        for ii = 1:nkins
            Lm = cell2mat(Lmax(ii,:));
            Lr = cell2mat(Lraw(ii,:));
            Lproj = Lr*(Lm/norm(Lm))'*(Lm/norm(Lm));
            Lproj = bsxfun(@times, Lproj, sgns);
            Lprojnrm = arrayfun(@(ii) norm(Lproj(ii,:)), 1:size(Lproj,1));
            lrn(ii) = max(Lprojnrm)/norm(Lm);
        end
    elseif nflds == 1
        Lbest = cell2mat(Lbest);
        Lmax = cell2mat(Lmax);
        lrn = Lbest./Lmax;
    end

end
