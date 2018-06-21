function [c, z] = rouse(h, b, cb, Rou, varargin)
    %rouse computes the Rouse-Vanoni profile for a single grain size and concentration
    %
    % [Zs, Cs] = rouse(h, b, cb, Rou) computes the Rouse-Vanoni
    % concentration profile for a single case. Required inputs are flow
    % depth h, the reference height b, near bed concentration cb, and Rouse
    % suspension parameter Rou (aka Zr). Function returns the concentration
    % profile c and corresponding elevations above the bed z. Calculation
    % region is split into 50 equally spaced elvalution points from b to h,
    % see below for other options.
    %
    % [Zs, Cs] = rouse(h, b, cb, Rou, varargin) optionally takes a final
    % argument to dictate the evaluation points. If final argument is a
    % scalar n the calculation is divided into n equally spaced points from
    % b to h. If the argument is a vector v then v is used directly
    % for the evaluation points. Points in v outside the interval
    % [b h] will not be evaluated.
    %
    
    if ~isempty(varargin)
        if length(varargin) > 1
            warning('Too many arguments supplied, only using the first optional argument')
        end
        varargdims = size(varargin{1});
        if any(varargdims > 1)
            % its a vector
        else
            %its a scalar
        end
    else
        n = 50;
        z = linspace(b, h, n)';
    end
    
    
    hbb = (h - b) / b; % this is ((H-b)/b), a constant
    c = cb .* ( ((h-z)./z) ./ hbb ) .^ Rou;
    
end
