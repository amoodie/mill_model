function [vn, zn] = normalize_model(v, z, varargin)
    %normalize_model will normalize dimensional profiles to interval [0 1]
    %
    % [vn, zn] = normalize_model(v, z) calculates the normalized profile on
    % the interval [0 1] for a height vector z and value vector v, such
    % that the function is agnostic to velocity or concentration profiles.
    % Note that profile is normalized to the value nearest the bed, and
    % elevation values are normalized from [0 max(z)].
    %
    % [vn, zn] = normalize_model(v, z, v0) optionally takes a third scalar
    % argument for normalizing the profile to a given value v0. This is
    % especially helpful in the case of normalizing velocity profiles to u*
    % values.
    %
    
    if ~isempty(varargin)
        v0 = varargin{1};
    else
        [~, minzidx] = min(z);
        v0 = v(minzidx);
    end
    
    zn = z ./ max(z);
    vn = v ./ v0;
    
end
