
%% input parameters (mill dimensions)
con = load_conset('quartz-water'); % constants for quartz in water
H = 0.5; % total flume water height
h = 0.4; % height of sediment suspension above the bed
d = 0.2; % interior diameter
rpm = 1000; % setting revolutions per minute of the spinner mill
S = 1e-6; % slope is a parameter in the Zu calculation? Cannot be zero!
Beta = 2; % adjustment coefficient to the spinner mills conc-profile

%% input grain size distribution
gs = [41.7584195, 0.039569;
        51.8469785, 1.499221;
        64.372867,	6.197118;
        79.9249275,	13.954702;
        99.2342635,	21.134719;
        123.208608,	23.1038995;
        152.974996,	18.5011895;
        189.9327475, 10.6541;
        235.819248, 4.101679;
        292.791625, 0.8138035]; % grain size distribution, col1 is actual grain size, col2 is fraction at size
gs(:, 1) = gs(:, 1) .* 1e-6;

%% rpm solver (NEED TO LOOK UP!!)
rpm2ustar = (@(rpm2) 0.05 / sqrt(1000) * sqrt(rpm2));
if false
    figure();
    plot(linspace(1, 1000, 100), rpm2ustar(linspace(1, 1000, 100)), 'o-')
    xlabel('rpm'); ylabel('u_*');
end


%% solved parameters
r = d/2; % interior radius
ustar = rpm2ustar(rpm); % ustar
ws = get_DSV(gs(:, 1), 0.7, 3.5, con);
Rep = (sqrt(con.R .* con.g .* gs(:, 1)) .* gs(:, 1)) ./ con.nu;
D50 = find_Dxx(gs, 50);
[~, lambda] = makeDistToData(gs);


%% concentration profile model
b = h * 0.05;
Xi = (ustar ./ ws) .* (Rep .^ 0.6) .* (S .^ 0.08) .* (gs(:, 1) ./ D50) .^ 0.2; % some entrainment number in WP model
Es = (gs(:, 2) / 100) .* entr_WP04(lambda, Xi);
Rou = ws ./ (Beta .* 0.41 .* ustar);


for c = 1:size(gs, 1)
    [Cs(:, c), Zs(:, c)] = rouse(h, b, Es(c), Rou(c));
    [CsNorm(:, c), ZsNorm(:, c)] = normalize_model(Zs(:, c), Cs(:, c));
end

CsSum = nansum(Cs, 2);
ZsSum = nanmean(Zs, 2);
[ZsSumNorm, CsSumNorm] = normalize_model(ZsSum, CsSum);
bulkRou = nansum(Rou .* (gs(:,2) ./ 100)');


%     stnPred.d50Rou = get_DSV(stationStruct.gsSummNearBedNWnorm.d50*1e-6, 0.7, 3.5, load_conset('quartz-water')) / ...
%         (0.41 * stationStruct.Velocity.ustarBest);
%     stnPred.Cbari = trapz(stnPred.Zs(:,1), stnPred.Cs, 1) ./ stnModel.params.flowDepth;
%     stnPred.CbariSum = nansum(stnPred.Cbari, 2);
%     stationStruct.concProf.pred = stnPred;

if true
    figure();
    plot(CsSum, ZsSum, 'ok')
end


