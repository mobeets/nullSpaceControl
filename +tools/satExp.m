function y = satExp(x, th)
    y = th(1) - (th(1)-th(2))*exp(-x/th(3));
end
