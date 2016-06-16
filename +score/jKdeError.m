function scores = jKdeError(P, Ph)
    
    scFcn = @(y,yh) sum((y(:) - yh(:)).^2); % l2 norm
    if ~isa(P, 'cell') % not split by thetas
        scores = scFcn(P, Ph);
        return;
    end
    
    if numel(P) > 1
        assert(numel(size(P{1})) == 2); % assumes 2d kde
    end    
    scores = arrayfun(@(ii) scFcn(P{ii}, Ph{ii}), 1:numel(P));

end
