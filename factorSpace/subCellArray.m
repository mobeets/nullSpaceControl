function newCA = subCellArray(oldCA,idxs)

assert(ismember(1,size(oldCA))) % row or column vector
assert(ismember(1,size(idxs))) % row or column vector

if size(idxs,2) == 1
    idxs = idxs'; % Need row vector for for loop below
end

newCA = cell(0,1);

counter = 0;
for i = idxs
    counter = counter + 1;
    
    newCA{counter} = oldCA{i};
end