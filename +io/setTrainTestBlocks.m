function D = setTrainTestBlocks(D, trainInd, testInd)

    B{1} = D.blocks(1);
    B{2} = D.blocks(2);
    B{3} = D.blocks(3);
    
    D.blocks(1) = B{trainInd};
    D.blocks(2) = B{testInd};
    
end
