function [long, lam] = makeDistToData(gs)
    gsCt = floor( gs(:, 2) .* 10 );
    gsNum = gs(:,1);
    nR = nansum( gsCt ); % number of rows to fill out
    nC = size(gs, 1); % number of grain classes
    long = NaN(nR, 1);
    f = 1; % initialize filled to idx
    for j = 2:nC
        nF = gsCt(j); % number of slots to fill with this grain class
        long(f:(f+nF-1)) = repmat(gsNum(j), nF, 1);
        f = f+nF;
    end
    longPhi = -1 .* log2(long./1000);
    longStd = std(longPhi, 'omitnan');
    lam = 1 - (0.28 .* longStd);
end

