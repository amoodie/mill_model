
clear all

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
mill.ustar = 0.05; % shear velocity in m/s
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
    % select appropriate params
    mill.D = gs.class(i) * 1e-6;
    
    % calculate the denstity strat profile
    [un1gsDS, cn1gsDS, u1gsDS, c1gsDS, ~] = denstrat_1class(mill, soln, opts, con);
    uDS(:, i) = u1gsDS .* (gs.perc(i) / 100);
    cDS(:, i) = c1gsDS .* (gs.perc(i) / 100);
    
    % calculate the rouse profile
    [cn1gsRou, c1gsRou] = rouse_1class(mill, opts, con);
    cRou(:, i) = c1gsRou .* (gs.perc(i) / 100);
end

%% sum the grain classes into one profile
uSumDS = sum(uDS, 2);
cSumDS = sum(cDS, 2);
cSumRou = sum(cRou, 2);


%% make some plots
figure(); hold on;
plot(cSumRou, mill.H .* mill.zeta)
plot(cSumDS, mill.H .* mill.zeta)
legend('no strat', 'strat')

gsmap = parula(size(gs, 1));
figure(); hold on;
[l(1)] = plot([0 0], [NaN, NaN], 'LineStyle', 'none');
for i = 1:size(gs, 1)
    plot(cRou(:, i), mill.H .* mill.zeta, 'LineStyle', '--', 'Color', gsmap(i, :), 'LineWidth', 1.5);
    [l(i+1)] = plot(cDS(:, i), mill.H .* mill.zeta, 'LineStyle', '-', 'Color', gsmap(i, :), 'LineWidth', 1.5);
end
legend(l, vertcat({'gs = '}, cellstr(num2str(round(gs.class, 2)))) )
xlabel('conc (-)')
ylabel('height (m)')

