function allErrorByKin(D, Hs)

    subplot(3,1,1);
    plot.errorByKin(Hs, 'errOfMeansByKin');
    subplot(3,1,2);
    plot.errorByKin(Hs, 'covErrorShapeByKin');
    subplot(3,1,3);
    plot.errorByKin(Hs, 'covErrorOrientByKin');
    plot.subtitle(D.datestr);

end
