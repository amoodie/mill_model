function [c, z] = rouse(z0, cb, Rou)
    %rouse computes the Rouse-Vanoni profile for a single grain size and concentration
    %
    % [c, z] = rouse(z, cb, Rou) computes the Rouse-Vanoni concentration
    % profile for a single case. Required inputs are a vector of elevations
    % z to evaluate the concentration profile at, near bed concentration
    % cb, and Rouse suspension parameter Rou (aka Zr). Function returns the
    % concentration profile c and corresponding elevations above the bed z.
    % Calculation region is split into 50 equally spaced elvalution points
    % from b to h, see below for other options.
    %
    % [c, z] = rouse(z, cb, Rou) optionally if first argument is a scalar,
    % the profile is calculated from z*0.5 to z in 50 equally spaced
    % points.
    %
    

    if any(size(z0) > 1)
        % vector supplied, check interval and proceed
        if ~ismatrix(z0) % check if input is matrix
            warning('Matrix input for z vector not supported. Using first column only.')
            z = z0(:, 1);
        end
        z = z0;
    else
        n = 50;
        b = z0 * 0.05;
        z = linspace(b, z0, n)';
    end
    
    % check all in range
    if any(z < 0)
        warning('Negative evaluation points supplied, removing.')
        z = z(~(z < 0));
    end
    h = max(z);
    b = min(z);
    
    % solve
    hbb = (h - b) / b; % this is ((h - b) / b), a constant
    c = cb .* ( ((h - z) ./ z) ./ hbb ) .^ Rou;
    
end
