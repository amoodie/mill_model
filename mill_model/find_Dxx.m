function [Dxx] = find_Dxx(gs, xx)
    %find_Dxx located the xx-th percentile in the grainsize distribution.
    % 
    % [Dxx] = find_Dxx(gs, xx) calculates the xx-th percentile in the grain size distribution gs and returns this value Dxx in the same units of gs.  

    % check if cumulative already (using all(gs(2:end)-gs(1:end-1)) >= 0, or the other way around?)
    % check if the values are fractions or percents.
    cumul = cumsum(gs(:, 2));
    Dxx = interp1(cumul, gs(:, 1), xx);

end
