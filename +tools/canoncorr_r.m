function r = canoncorr_r(X,Y)
    ix = ~(any(isnan(X),2) | any(isnan(Y),2));
    [~,~,r,~,~] = canoncorr(X(ix,:),Y(ix,:));
    r = r(1);
end
