function [un, cn, soln] = denstrat_1class(mill, soln, opts, con)
    % a function to calculate the density stratified profile for one grain
    % size class. Requires inputs.
    %
    % inputs:
    %   mill = struct with D, H, kc, ustar, zeta
    %   soln = structure with fields: tol, nmax
    %   opts = additional options
    %   con = conset
    %
    % outputs:
    %   un = velocity profile
    %   cn = concentration profile
    %   soln = the solution structure with solution information for debug
    %
    
    % determine reference concentration near bed
    if opts.setCb
        Cb = opts.Cb; % set the ref conc here if manual
    else
        Aa = 0.00000013; % Garcia-Parker constant
        ustars = mill.ustar; % skin friction component
        Rep = sqrt((con.R) * con.g * mill.D)*(mill.D) / con.nu; % particle reynolds number
        vs = get_DSV(mill.D, 0.7, 3.5, con); % settling velocity
        Zgp = (ustars / vs) * Rep ^ (0.6); % Garcia and Parker, Z number
        Cb = Aa * Zgp ^ 5 / (1 + Aa / 0.3 * Zgp ^ 5); % reference concentration 
    end
    Hr = mill.H / mill.kc;
    ustarr = mill.ustar / vs; % Ratio of shear velocity to fall velocity
    unr = 1 / 0.4 * log(30 * 0.05 * Hr);
    Ristar = con.R * con.g * mill.H * Cb / mill.ustar^2;

    % preallocate vectors
    Ri = zeros(size(mill.zeta));
    Fstrat = ones(size(mill.zeta));
    un = unr .* ones(size(mill.zeta)); % velocity profile
    cn = ones(size(mill.zeta)); % conventration profile
    intc = zeros(size(mill.zeta));
    
    % set soln params
    soln.converges = false; % boolean for whether iteration is within convergence error
    soln.bombs = false; % boolean for if the equations do not converge
    soln.n = 0; % iteration number
    
    % initilize a guess profile with the initial params (Rouse-Vanoni solution)
    [un, cn, Fstrat] = ComputeUCnormal(un, cn, Fstrat, intc, ustarr, Ristar, mill, soln, con);
    ui = un; % save the initial velocity  
    ci = cn; % and concentration profile
    
    solnFig = figure('Visible', 'off'); % solution figure
    
    while ~or(soln.bombs, soln.converges) % while not converged or exceeded iternations
        
        soln.n = soln.n + 1; % iterate
        
        un0 = un; % save old for convergence
        cn0 = cn;
        
        [un, cn, Fstrat] = ComputeUCnormal(un, cn, Fstrat, intc, ustarr, Ristar, mill, soln, con);
        [soln] = CheckConvergence(un, cn, un0, cn0, mill, soln);
        
        if soln.show_iter
            figure(solnFig);
            title(['solving D = ', num2str(mill.D)])
            subplot(1, 2, 1)
                plot(un, mill.zeta)
            subplot(1, 2, 2)
                plot(cn, mill.zeta)
            drawnow
        end
    end
    % end solution
    
    if soln.bombs
        error('no convergence')
    else
        if soln.show_final
            % plot the final result
            figure()
            subplot(1, 2, 1); hold on;
                plot(mill.ustar .* ui/100, mill.H .* mill.zeta, 'LineWidth', 1.5)
                plot(mill.ustar .* un/100, mill.H .* mill.zeta, 'LineWidth', 1.5)
                xlabel('velocity (m/s)')
                ylabel('dist above bed (m)')
            subplot(1, 2, 2); hold on;
                plot(Cb .* ci, mill.H .* mill.zeta, 'LineWidth', 1.5)
                plot(Cb .* cn, mill.H .* mill.zeta, 'LineWidth', 1.5)
                xlabel('conc. profile (1)')
                legend('no strat', 'strat')
        end
    end



end

function [un, cn, Fstrat] = ComputeUCnormal(un, cn, Fstrat, intc, ustarr, Ristar, mill, soln, con)

    % this must be solved from the bed up sequentially
    for i = 2:(mill.nzeta + 1)
        ku1 = 1 / (con.kappa * mill.zeta(i - 1) * Fstrat(i - 1));
        ku2 = 1 / (con.kappa * mill.zeta(i) * Fstrat(i));
        un(i) = un(i - 1) + 0.5 * (ku1 + ku2) * mill.dzeta;
        kc1 = 1 / ((1 - mill.zeta(i - 1)) * mill.zeta(i - 1) * Fstrat(i - 1));
        kc2 = 1 / ((1 - mill.zeta(i)) * mill.zeta(i) * Fstrat(i));
        intc(i) = intc(i - 1) + 0.5 * (kc1 + kc2) * mill.dzeta;
        cn(i) = exp(-1 / con.kappa / ustarr * intc(i));
    end
    
    una = trapz(mill.zeta, un);
    cna = trapz(mill.zeta, cn);
    qs = trapz(mill.zeta, cn .* un);

    Ri = Ristar .* (con.kappa .* mill.zeta .* Fstrat) ./ (ustarr .* (1 - mill.zeta)) .* cn;
    X = (1.35 .* Ri) ./ (1 + (1.35 .* Ri));
    Fstrat = 1 ./ (1 + (10 .* X));
    
end

function [soln] = CheckConvergence(un, cn, un0, cn0, mill, soln)
    
    Error = 0;
    % vectorize this
    for i = 1:mill.nzeta
        ern = abs(2 * (un(i) - un0(i)) / (un(i) + un0(i)));
        erc = abs(2 * (cn(i) - cn0(i)) / (cn(i) + cn0(i)));
        if ern > Error
            Error = ern;
        end
        if erc > Error
            Error = erc;
        end
    end
    if Error < soln.Ep
        soln.converges = true;
        soln.bombs = false;
    else
        soln.converges = false;
        if soln.n >= soln.nmax
            soln.bombs = true;
        else
            soln.bombs = false;
        end
    end
end

