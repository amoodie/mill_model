function [Es, EsNoLim] = entr_WP04(lambda, Xi)
    
    Zu = lambda .* Xi;
    B = 7.8 * 10^-7;
    Es = (B .* Zu .^ 5) ./ (1 + ((B / 0.3) .* Zu .^ 5));
    EsNoLim = (B .* Zu .^ 5);

end
