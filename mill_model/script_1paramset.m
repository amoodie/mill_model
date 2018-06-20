
%% load conset and colorset(?)
[con] = load_conset('quartz-water');
con.kappa = 0.4; % von Karman


%% load grain size and ensure it is ready for use in models
[gs] = load_grainsize(fullfile('..', 'grainsize_distributions', 'distribution_KC4.csv'));
gs.Properties.VariableNames = {'class', 'perc'};


%% enter parameters for the spinner mill
mill.D = []; % assigned in loop, sediment grain size in m
mill.H = 0.5; % flow depth in m
mill.kc = 2e-3; % composite roughness height in m (including effect of bedforms if present)
mill.ustar = 0.15; % shear velocity in m/s
mill.zetar = 0.05; % reference height for beginning zeta vector
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
% opts.floc = floc?
% opts.flocthresh = 30e-6; % everything smaller becomes this size
% define ref conc or calc it


%% process any relevant options


%% compute the concentration profile for each grain class
for i = 1:size(gs, 1)
    mill.D = gs.class(i) * 1e-6;
    [un1gs, cn1gs, u1gs, c1gs, ~] = denstrat_1class(mill, soln, opts, con);
    u(:, i) = u1gs .* (gs.perc(i) / 100);
    c(:, i) = c1gs .* (gs.perc(i) / 100);
end

%% sum the grain classes into one profile
uSum = sum(u, 2);
cSum = sum(c, 2);

figure()
plot(cSum, mill.H .* mill.zeta)

