function ths = computeAngles(vecs)

    ths = arrayfun(@(t) tools.computeAngle(vecs(t,:), [1; 0]), ...
        1:size(vecs,1))';
    ths = mod(ths, 360);
    
end