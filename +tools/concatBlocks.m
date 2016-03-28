function trs = concatBlocks(D)

    B1 = D.blocks(1);
    flds = fieldnames(B1);
    
    trs = struct();
    for ii = 1:numel(flds)
        if isa(B1.(flds{ii}), 'struct')
            continue;
        end
        trs.(flds{ii}) = [];
    end
    
    for ii = 1:numel(D.blocks)
        B = D.blocks(ii);
        assert(isequal(flds, fieldnames(B)));
        for jj = 1:numel(flds)
            if isa(B.(flds{jj}), 'struct') || ~isfield(trs, flds{jj})
                continue;
            end
            trs.(flds{jj}) = [trs.(flds{jj}); B.(flds{jj})];
        end
    end

end
