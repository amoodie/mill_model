function stratify()
    % this function will run the Gary Parker ebook code in Matlab:
    % RTe-bookSuspSedDensityStrat
    %
    % all initial parameters are the same.
    % all variable names have been left the same.
    % comments were added by AJM
    % none of the code has been vectorized for speed.
    %

    zetar = 0.05; % reference height for beginning zeta vector
    nintervals = 50; % number of points in zeta
    kappa = 0.4; % von Karman
    g = 981; % gravitational constant
    Ep = 0.001; % convergence tolerance
    nmax = 200; % maximum iterations
    show_solution = true; % whether to show the solution converge?

    Rp1 = 2.65; %C5 Specific gravity of sediment
    D = 0.1; %C6 Sediment grain size in mm
    H =	1; %C7 Flow depth in m
    kc = 2; %C8 Composite roughness height in mm (including effect of bedforms if present)
    ustar = 2; %C9	Shear velocity in cm/s
    nu = 0.01; %C10	Kinematic viscosity of water, cm^2/s

    % Sub GetInputData()
    Aa = 0.00000013; % garcia and parker constant
    setCr = false; % do you want to manually set the reference concentration?
    if setCr
        Cr = 1e-3; % set the ref conc here if manual
    else
        ustars = ustar; % skin friction component
        Rep = sqrt((Rp1-1)*981*(D/10))*(D/10)/nu; % particle reynolds number
        vs = get_DSV(D*1e-3, 0.7, 3.5) * 100; % settling velocity
        Zgp = (ustars / vs) * Rep ^ (0.6); % Garcia and Parker, Z number
        Cr = Aa * Zgp ^ 5 / (1 + Aa / 0.3 * Zgp ^ 5); % reference concentration
    end
    Hr = (H * 100) / (kc / 10);
    ustarr = ustar / (vs); % Ratio of shear velocity to fall velocity
    unr = 1 / 0.4 * log(30 * 0.05 * Hr);
    Ristar = (Rp1-1) * 981 * H * 100 * Cr / ustar^2;

    % Sub Initialize()
    dzeta = (1 - zetar) / nintervals; % spatial step in vertical
    for i = 1:nintervals+1
        zeta(i, 1) = zetar + dzeta * (i - 1);
        Ri(i) = 0;
        Fstrat(i) = 1;
    end
    Converges = false; % boolean for whether iteration is within convergence error
    Bombs = false; % boolean for if the equations do not converge
    n = 0; % iteration number
    un(1) = unr; % velocity profile
    cn(1) = 1; % conventration profile
    intc(1) = 0;
    
    % initilize a guess profile with the initial params (Rouse-Vanoni solution)
    [un, cn, unold, cnold, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar);
    ui = un; % save the initial velocity and concentration profiles for comparison 
    ci = cn;
    
     
    solnFig = figure('Visible', 'off'); % solution figure
    
    while ~or(Bombs, Converges) % while not converged or exceeded iternations
        n = n + 1; % iterate
        [un, cn, unold, cnold, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar);
        [Bombs, Converges] = CheckConvergence(n, nintervals, un, cn, unold, cnold, Ep, nmax);
        
        if show_solution
            figure(solnFig);
            subplot(1, 2, 1)
                plot(un, zeta)
            subplot(1, 2, 2)
                plot(cn, zeta)
            drawnow
        end
    end
    % end solution
    
    if Bombs
        error('no convergence')
    else
        % plot the final result
        figure()
        subplot(1, 2, 1); hold on;
            plot(ustar.*ui/100, H.*zeta, 'LineWidth', 1.5)
            plot(ustar.*un/100, H.*zeta, 'LineWidth', 1.5)
            xlabel('velocity (m/s)')
            ylabel('dist above bed (m)')
        subplot(1, 2, 2); hold on;
            plot(Cr.*ci, H.*zeta, 'LineWidth', 1.5)
            plot(Cr.*cn, H.*zeta, 'LineWidth', 1.5)
            xlabel('conc. profile (1)')
            legend('no strat', 'strat')
    end



end

function [un, cn, unold, cnold, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar)

    if n > 0
        for i = 1:nintervals + 1
            unold(i) = un(i);
            cnold(i) = cn(i);
        end
    else
        unold = un;
        cnold = cn;
    end
    for i = 2:nintervals + 1
        ku1 = 1 / (kappa * zeta(i - 1) * Fstrat(i - 1));
        ku2 = 1 / (kappa * zeta(i) * Fstrat(i));
        un(i) = un(i - 1) + 0.5 * (ku1 + ku2) * dzeta;
        kc1 = 1 / ((1 - zeta(i - 1)) * zeta(i - 1) * Fstrat(i - 1));
        kc2 = 1 / ((1 - zeta(i)) * zeta(i) * Fstrat(i));
        intc(i) = intc(i - 1) + 0.5 * (kc1 + kc2) * dzeta;
        cn(i) = exp(-1 / kappa / ustarr * intc(i));
    end
    una = 0.5 * dzeta * (un(1) + un(nintervals + 1));
    cna = 0.5 * dzeta * (cn(1) + cn(nintervals + 1));
    qs = 0.5 * dzeta * (un(1) * cn(1) + un(nintervals + 1) * cn(nintervals + 1));
    for i = 2:nintervals + 1
        una = una + dzeta * un(i);
        cna = cna + dzeta * cn(i);
        qs = qs + dzeta * un(i) * cn(i);
    end
    for i = 1:nintervals + 1
        Ri(i) = Ristar * (kappa * zeta(i) * Fstrat(i)) / (ustarr * (1 - zeta(i))) * cn(i);
        X = 1.35 * Ri(i) / (1 + 1.35 * Ri(i));
        Fstrat(i) = 1 / (1 + 10 * X);
    end

end

function [Bombs, Converges] = CheckConvergence(n, nintervals, un, cn, unold, cnold, Ep, nmax)
             
    if n > 0
        Error = 0;
        for i = 1:nintervals
            ern = abs(2 * (un(i) - unold(i)) / (un(i) + unold(i)));
            erc = abs(2 * (cn(i) - cnold(i)) / (cn(i) + cnold(i)));
            if ern > Error
                Error = ern;
            end
            if erc > Error
                Error = erc;
            end
        end
        if Error < Ep
            Converges = true;
            Bombs = false;
        else
            Converges = false;
            if n >= nmax
                Bombs = true;
            else
                Bombs = false;
            end
        end
    end
end

