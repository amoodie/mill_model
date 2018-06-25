
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
mill.ustar = []; % assigned in loop, shear velocity in m/s
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
ustar_range = linspace(0.01, 0.17, 12); % the ustars to test the mill at


%% process any relevant options


%% preallocate
uDS = zeros(length(mill.zeta), length(gs.class), length(ustar_range));
cDS = zeros(length(mill.zeta), length(gs.class), length(ustar_range));
cRou = zeros(length(mill.zeta), length(gs.class), length(ustar_range));
uSumDS = zeros(length(mill.zeta), length(gs.class));
cSumDS = zeros(length(mill.zeta), length(gs.class));
cSumRou = zeros(length(mill.zeta), length(gs.class));

%% compute the concentration profile for each grain class
for i = 1:length(ustar_range)
    % select the loop ustar
    mill.ustar = ustar_range(i);
    
    for j = 1:size(gs, 1)
        mill.D = gs.class(j) * 1e-6;
        
        % calculate the denstity strat profile
        [un1gsDS, cn1gsDS, u1gsDS, c1gsDS, ~] = denstrat_1class(mill, soln, opts, con);
        uDS(:, j, i) = u1gsDS .* (gs.perc(j) / 100);
        cDS(:, j, i) = c1gsDS .* (gs.perc(j) / 100);
        
        % calculate the rouse profile
        [cn1gsRou, c1gsRou] = rouse_1class(mill, opts, con);
        cRou(:, j, i) = c1gsRou .* (gs.perc(j) / 100);
    end
    
    % sum the grain classes into one profile
    uSumDS(:, i) = sum(uDS(:, :, i), 2);
    cSumDS(:, i) = sum(cDS(:, :, i), 2);
    cSumRou(:, i) = sum(cRou(:, :, i), 2);
end


%% make some plots

% plot the DS-Rou pairs for each ustar
nskip = 2;
ustar_plotidx = 1:nskip:length(ustar_range);
ustarmap = parula(length(ustar_plotidx));
figure(); hold on;
[l(1)] = plot([0 0], [NaN, NaN], 'LineStyle', 'none');
for i = 1:length(ustar_plotidx)
    ii = ustar_plotidx(i);
    plot(cSumRou(:, ii), mill.H .* mill.zeta, 'LineStyle', '--', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
    [l(i+1)] = plot(cSumDS(:, ii), mill.H .* mill.zeta, 'LineStyle', '-', 'Color', ustarmap(i, :), 'LineWidth', 1.5);
end
legend( l, vertcat({'u_* = '}, cellstr(num2str(round(ustar_range(ustar_plotidx), 2)'))) )
xlabel('conc (-)')
ylabel('height (m)')

