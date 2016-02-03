function U = randomUnitary(n)

    [U,~,~] = svd(rand(n));
    if det(U) > 0
        U(:,1) = -U(:,1);
    end
%     X = (randn(n) + i*randn(n))/sqrt(2);
%     [Q,R] = qr(X);
%     R = diag(diag(R)./abs(diag(R)));
%     U = Q*R;

end
