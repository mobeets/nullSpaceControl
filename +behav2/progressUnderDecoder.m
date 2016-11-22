function prog = progressUnderDecoder(B, dec)

    movVec = []; % diff(B.pos);
    vec2trg = B.vec2target;
    prog_fcn = @(t) movVec(t,:)*vec2trg(t,:)'/norm(vec2trg(t,:));
    prog = arrayfun(prog_fcn, 1:nt);

end
