% this script contains auxiliary calculation and calibrations needed in the
% process of the spinner mills experiments


%% voltage to rpm
volts = [1 2 3 4]; % a range of volts that the motor can run at
rpms_v = [2 3 4 5]; % the repsonse measured rpms of the disk

figure()
plot(volts, rpms_v, '-o', 'LineWidth', 1.5)
xlabel('volts')
ylabel('rpm')


%% rpm to reynolds stress (u*)
rpms_s = [1 2 3 4]; % rpms selected for calibration (could/should be same as above?)
upvps = [3 4 5 6]; % measured \bar{u'v'} at the nearest bed measurement feasible

figure()
plot(rpms_s, upvps, '-o', 'LineWidth', 1.5)
xlabel('rpm')
ylabel("\bar{u'v'}")


%% sediment needed for alluvial bed
% the more sediment goes into suspension, the more comes off the bed and
% the bed elevation lowers. We should add more sediment to the mill for the
% higher stresses to keep the bed at a constant elevation.
bedH = 0.02; % height of bed to maintain through all ustar expts
bedV = pi * (mill.diam/2) ^ 2 * bedH * 1000; % liters of sed needed with no suspension


%% sediment needed for total experiments
% based on estimates of total sediment withdrawal for each sample, adding
% more to the bed, how much sediment do I need *in total*