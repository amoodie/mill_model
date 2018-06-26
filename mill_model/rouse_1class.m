function [cn, c] = rouse_1class(mill, opts, con)
    % a function to calculate the standard Rouse-Vanoni profile for one grain
    % size class. Requires inputs.
    %
    % inputs:
    %   mill = struct with D, H, kc, ustar, zeta
    %   opts = additional options
    %   con = conset
    %
    % outputs:
    %   un = velocity profile
    %   cn = concentration profile
    %
    
    % determine reference concentration near bed
    if opts.setCb
        Cb = opts.Cb; % set the ref conc here if manual
    else
        Aa = 0.00000013; % Garcia-Parker constant
        ustars = mill.ustar; % skin friction component
        Rep = sqrt((con.R) * con.g * mill.D)*(mill.D) / con.nu; % particle reynolds number
        ws = get_DSV(mill.D, 0.7, 3.5, con); % settling velocity
        Zgp = (ustars / ws) * Rep ^ (0.6); % Garcia and Parker, Z number
        Cb = Aa * Zgp ^ 5 / (1 + Aa / 0.3 * Zgp ^ 5); % reference concentration 
    end
    Hr = mill.H / mill.kc;
    ustarr = mill.ustar / ws; % Ratio of shear velocity to fall velocity
    unr = 1 / 0.4 * log(30 * 0.05 * Hr);
    Ristar = con.R * con.g * mill.H * Cb / mill.ustar^2;

    Rou = ws ./ (mill.Beta .* 0.41 .* mill.ustar);
    
    [c, z] = rouse(mill.zeta, Cb, Rou);
    [cn, zn] = normalize_model(c, mill.zeta);
    
end

