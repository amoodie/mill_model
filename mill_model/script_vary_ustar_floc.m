
clear all

%% load conset and colorset(?)
[con] = load_conset('quartz-water');
con.kappa = 0.4; % von Karman


%% load grain size and ensure it is ready for use in models
[gs] = load_grainsize(fullfile('..', 'grainsize_distributions', 'distribution_KC4.csv'));
gs.Properties.VariableNames = {'class', 'perc'};


%% enter parameters for the spinner mill
mill.D = []; % assigned in loop, sediment grain size in m
mill.H = 0.5; % flow depth in m (stationary water, above bed!)
mill.diam = 0.2; % mill diameter in m
mill.V = pi * (mill.diam/2) ^ 2 * mill.H; % volume of water in m3
mill.Vl = mill.V * 1000; % volume in liters
mill.kc = 2e-3; % composite roughness height in m (including effect of bedforms if present)
mill.ustar = []; % assigned in loop, shear velocity in m/s
mill.Beta = 1; % the adjustment factor to the spinner mill (?)
mill.zetar = 0.05 .* mill.H; % reference height for beginning zeta vector
mill.nzeta = 50; % number of points in zeta
mill.zeta = linspace(mill.zetar, 1, mill.nzeta+1)';
mill.dzeta = mill.zeta(2) - mill.zeta(1);


%% prepare the solver options
soln.Ep = 0.001; % convergence tolerance
soln.nmax = 200; % maximum iterations
soln.show_iter = false;
soln.show_final = false;


%% select any other options
opts.setCb = false;
opts.Cb = 1e-3;

opts.floc = true;
opts.flocthresh = 40e-6; % everything smaller becomes this size

opts.uncert = 0.1; % percentage uncertainty in all factors

ustars = linspace(0.02, 0.10, 12); % the u*s to test the mill at
samp_z = [0.1, 0.15, 0.25, 0.5, 0.75] .* mill.H;


%% process any relevant options
if opts.floc
    flocidx = find(gs.class < opts.flocthresh);
end


%% preallocate
uDS = zeros(length(mill.zeta), length(gs.class), length(ustars));
cDS = zeros(length(mill.zeta), length(gs.class), length(ustars));
cRou = zeros(length(mill.zeta), length(gs.class), length(ustars));
uSumDS = zeros(length(mill.zeta), length(gs.class));
cSumDS = zeros(length(mill.zeta), length(gs.class));
cSumRou = zeros(length(mill.zeta), length(gs.class));


%% compute the concentration profile for each grain class
for i = 1:length(ustars)
        
    for j = 1:size(gs, 1)
        mill.D = gs.class(j) * 1e-6;
        
        % calculate the denstity strat profile
        mill.ustar = ustars(i);
        [un1gsDS, cn1gsDS, u1gsDS, c1gsDS, ~] = denstrat_1class(mill, soln, opts, con);
        uDS(:, j, i) = u1gsDS .* (gs.perc(j) / 100);
        cDS(:, j, i) = c1gsDS .* (gs.perc(j) / 100);
        
        % calculate the rouse profile
        [cn1gsRou, c1gsRou] = rouse_1class(mill, opts, con);
        cRou(:, j, i) = c1gsRou .* (gs.perc(j) / 100);
        
        % calculate lower and upper bounds assuming uncert in ustar
        mill.ustar = ustars(i) * (1 - opts.uncert); % lower bound uncertainty
        [~, ~, ~, c1gsDSlow, ~] = denstrat_1class(mill, soln, opts, con);
        cDSlow(:, j, i) = c1gsDSlow .* (gs.perc(j) / 100);
        
        [~, c1gsRoulow] = rouse_1class(mill, opts, con);
        cRoulow(:, j, i) = c1gsRoulow .* (gs.perc(j) / 100);
        
        mill.ustar = ustars(i) * (1 + opts.uncert); % upper bound uncert
        [~, ~, ~, c1gsDShigh, ~] = denstrat_1class(mill, soln, opts, con);
        cDShigh(:, j, i) = c1gsDShigh .* (gs.perc(j) / 100);
        
        [~, c1gsRouhigh] = rouse_1class(mill, opts, con);
        cRouhigh(:, j, i) = c1gsRouhigh .* (gs.perc(j) / 100);
    end
    
    % sum the grain classes into one profile
    uSumDS(:, i) = sum(uDS(:, :, i), 2);
    cSumDS(:, i) = nansum(cDS(:, :, i), 2);
    cSumRou(:, i) = sum(cRou(:, :, i), 2);
    cSumDSlow(:, i) = nansum(cDSlow(:, :, i), 2);
    cSumDShigh(:, i) = nansum(cDShigh(:, :, i), 2);
    cSumRoulow(:, i) = sum(cRoulow(:, :, i), 2);
    cSumRouhigh(:, i) = sum(cRouhigh(:, :, i), 2);
end

%% determine experimental observables
% find the concentration at each vs the Rouse conc
czDS = interp1(mill.zeta, cSumDS, samp_z); % predicted conc at sampling ports
czRou = interp1(mill.zeta, cSumRou, samp_z);

figure(); hold on;
subplot(3, 1, 1)
    plot(ustars, czDS, '-o', 'LineWidth', 1.5)
    legend(num2str(samp_z'), 'Location', 'NorthWest')
    ylabel('conc of samp (DS) @z')
subplot(3, 1, 2)
    plot(ustars, czRou - czDS, '-o', 'LineWidth', 1.5)
    ylabel('Rou\_mdl - DS @z')
subplot(3, 1, 3)
    plot(ustars, czDS .* 2650 * 0.5, '-o', 'LineWidth', 1.5)
    ylabel('mass of samp @z in 0.5 L (g)')
    xlabel('u_* (m/s)')


% find the mass of sediment



%% make some plots

% plot the DS-Rou pairs for each ustar
nskip = 2;
ustar_plotidx = 1:nskip:length(ustars);
ustarmap = parula(length(ustar_plotidx));
figure(); hold on;
[l(1)] = plot([0 0], [NaN, NaN], 'LineStyle', 'none');
for i = 1:length(ustar_plotidx)
    ii = ustar_plotidx(i);
    plot(cSumRou(:, ii), mill.H .* mill.zeta, 'LineStyle', '--', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
    [l(i+1)] = plot(cSumDS(:, ii), mill.H .* mill.zeta, 'LineStyle', '-', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
end
legend( l, vertcat({'u_* = '}, cellstr(num2str(round(ustars(ustar_plotidx), 2)'))) )
xlabel('conc (-)')
ylabel('height (m)')


%% look at uncertainty explicitly
ustar_plotidx = [1, floor(length(ustars)/2), length(ustars)];
ustarmap = parula(length(ustar_plotidx));
figure(); hold on;
[l(1)] = plot([0 0], [NaN, NaN], 'LineStyle', 'none');
for i = 1:length(ustar_plotidx)
    ii = ustar_plotidx(i);
    patch([cSumRoulow(:, ii); flipud(cSumRouhigh(:, ii))], [mill.H .* mill.zeta; flipud(mill.H .* mill.zeta)], ...
        [ustarmap(i, :)], 'FaceAlpha', 0.2, 'EdgeAlpha', '0')
    patch([cSumDSlow(:, ii); flipud(cSumDShigh(:, ii))], [mill.H .* mill.zeta; flipud(mill.H .* mill.zeta)], ...
        [ustarmap(i, :)], 'FaceAlpha', 0.2, 'EdgeAlpha', '0')
    plot(cSumRou(:, ii), mill.H .* mill.zeta, 'LineStyle', '--', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
    [l(i+1)] = plot(cSumDS(:, ii), mill.H .* mill.zeta, 'LineStyle', '-', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
end
legend(l, vertcat({'u_* = '}, cellstr(num2str(round(ustars(ustar_plotidx), 2)'))) )
xlabel('conc (-)')
ylabel('height (m)')




j=1;
