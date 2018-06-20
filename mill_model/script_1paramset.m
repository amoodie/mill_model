
%% load conset and colorset(?)
[con] = load_conset('quartz-water');
con.kappa = 0.4; % von Karman


%% load grain size and ensure it is ready for use in models
[gs] = load_grainsize(fullfile('..', 'grainsize_distributions', 'distribution_KC4.csv'));
gs.Properties.VariableNames = {'class', 'perc'};


%% enter parameters for the spinner mill
mill.D = []; % assigned in loop, sediment grain size in m
mill.H = 1; % flow depth in m
mill.kc = 2e-3; % composite roughness height in m (including effect of bedforms if present)
mill.ustar = 0.02; % shear velocity in m/s
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


%% compute the concentration profile for each grain class
for c = 1:size(gs, 1)
    mill.D = gs.class(c) * 1e-6;
    [un(:, c), cn(:, c)] = denstrat_1class(mill, soln, opts, con);
    
end

%% sum the grain classes into one profile
unSum = sum(un, 2);
cnSum = sum(cn, 2);

figure()
plot(cnSum, mill.zeta)

