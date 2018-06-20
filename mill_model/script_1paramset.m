

%% load grain size and ensure it is ready for use in models
[gs] = load_grainsize(fullfile('..', 'grainsize_distributions', 'distribution_KC4.csv'));
gs.Properties.VariableNames = {'class', 'perc'};

%% enter parameters for the spinner mill


%% prepare anything else to pass to the solver


%% compute the concentration profile for each grain class


%% sum the grain classes into one profile
