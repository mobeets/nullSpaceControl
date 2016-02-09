function [s, s2, s3, S, S2, S3] = covError(zNull, zNull0)
    
    S = nan(numel(zNull), 1);
    S2 = nan(numel(zNull), 1);
    S3 = nan(numel(zNull), 1);
    for ii = 1:numel(zNull)
        [S(ii),S2(ii),S3(ii)] = score.compareCovs(zNull{ii}, zNull0{ii});
    end
    s = mean(S);
    s2 = mean(S2);
    s3 = mean(S3);

end
