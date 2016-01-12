function newCA = subCellArray(oldCA, idxs)

assert(ismember(1, size(oldCA))) % row or column vector
assert(ismember(1, size(idxs))) % row or column vector

if size(idxs,2) == 1
    idxs = idxs'; % Need row vector in for loop below
end

newCA = cell(numel(idxs),1);
for ii = 1:numel(idxs)
    newCA{ii} = oldCA{idxs{ii}};
end
