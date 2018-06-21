function [c, z] = rouse(z, cb, Rou)
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
    
%     if ~isempty(varargin)
%         if length(varargin) > 1
%             warning('Too many arguments supplied, only using the first optional argument')
%         end
%         varargdims = size(varargin{1});
%         if any(varargdims > 1)
%             % its a vector
%         else
%             %its a scalar
%         end
%     else
%         n = 50;
%         z = linspace(b, h, n)';
%     end
    if any(size(z) > 1)
        % vector supplied, check interval and proceed
        if ~ismatrix(z)
            error('
        end
    else
        n = 50;
        z = linspace(b, h, n)';
    end
    
    hbb = (h - b) / b; % this is ((H-b)/b), a constant
    c = cb .* ( ((h-z)./z) ./ hbb ) .^ Rou;
    
end
