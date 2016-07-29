function deg = angleBetweenMappings(B1, B2)
% B1 and B2 could be, e.g., NB1 and NB2
    deg = rad2deg(subspace(B1, B2));
end
