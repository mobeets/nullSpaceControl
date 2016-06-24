function ds = getAngleDistance(d1, d2)
    ds = abs(mod((d1-d2 + 180), 360) - 180);
end
