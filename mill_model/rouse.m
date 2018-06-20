function [Zs, Cs] = rouse(h, b, cb, Rou)

    n = 50;
    hbb = (h - b) / b; % this is ((H-b)/b), a constant
    Zs = linspace(b, h, n)';
    Cs = cb .* ( ((h-Zs)./Zs) ./ hbb ) .^ Rou;
    
end
