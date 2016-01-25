function [Y1, R, Yfcn] = rotatePrediction(Y0, Y1)
% find a rotation of Y1 so that Y0 is closest to Y1
% src: http://nghiaho.com/?page_id=671

    [U,S,V] = svd(corr(Y0, Y1));
%     diag(S)./sum(diag(S));
    R = V*U';
    if det(R) == -1 % reflect
        R(:,end) = R(:,end)*-1;
        assert(det(R) == 1);
    end

    center = @(Y) bsxfun(@minus, Y, mean(Y));
    assert(norm(center(Y0) - center(Y1)) >= ...
        norm(center(Y0) - center(Y1)*R));
%     Y1 = bsxfun(@plus, center(Y1)*R, mean(Y1));
    Yfcn = @(Yc) bsxfun(@plus, center(Yc)*R, mean(Yc));
    Y1 = Yfcn(Y1);

end
