function [cn, zn] = normalize_model(z, c)
    zn = z ./ z(end);
    cn = c ./ c(1);
    
end
