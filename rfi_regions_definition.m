% This script defines the RFI detection regions for the SBAS C/N0 value 
% over received power metric. Note the received power is adjusted for the 
% PSD of the GPS L1 C/A signal. See the publication "GNSS Jamming and 
% Spoofing Monitoring Using Low-Cost COTS Receivers" for more details.
%
% Author: Argyris Kriezis
% Last Modified: Jan 7th 2026
%
% Input: Mean SBAS C/N0, Mean Received Power 
% Output: RFI Detection Regions

clear all
clc

mean_SBAS_cn0 = 46; % dBW-Hz
mean_rx_power = -185; % dBW/Hz

% Define Grid
[xGrid, yGrid] = meshgrid(-200:-50, 15:60);

% Error Region
errorRegion_logic = (xGrid < mean_rx_power-2);
errorRegion = [xGrid(errorRegion_logic),yGrid(errorRegion_logic)];

% Nominal Region
nominalRegion_logic = (xGrid == mean_rx_power) & (yGrid >= mean_SBAS_cn0-8) & (yGrid <= mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power-1) & (yGrid >= mean_SBAS_cn0-7) & (yGrid <= mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power-2) & (yGrid >= mean_SBAS_cn0-6) & (yGrid <= mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power+1) & (yGrid >= mean_SBAS_cn0-7) & (yGrid <= mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power+2) & (yGrid >= mean_SBAS_cn0-6) & (yGrid <= mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power+3) & (yGrid >= mean_SBAS_cn0-3) & (yGrid <= mean_SBAS_cn0+3);
nominalRegion = [xGrid(nominalRegion_logic),yGrid(nominalRegion_logic)];

% Blocked Region
blockedRegion_logic = (xGrid == mean_rx_power) & (yGrid < mean_SBAS_cn0-8) ...
    | (xGrid == mean_rx_power-1) & (yGrid < mean_SBAS_cn0-7) ...
    | (xGrid == mean_rx_power-2) & (yGrid < mean_SBAS_cn0-6) ...
    | (xGrid == mean_rx_power+1) & (yGrid < mean_SBAS_cn0-7);
blockedRegion = [xGrid(blockedRegion_logic),yGrid(blockedRegion_logic)];

% Jamming Region
jammingRegion_logic = (xGrid >= mean_rx_power+4) & (yGrid <= (mean_SBAS_cn0 + 3) - (xGrid - mean_rx_power - 3)) & (yGrid > 26) ...
    | (xGrid == mean_rx_power+2) & (yGrid < mean_SBAS_cn0-6) & (yGrid > 26) ...
    | (xGrid == mean_rx_power+3) & (yGrid < mean_SBAS_cn0-3) & (yGrid > 26) ...
    | (xGrid >= mean_rx_power+2) & (yGrid <= 26);
jammingRegion = [xGrid(jammingRegion_logic),yGrid(jammingRegion_logic)];

% Spoofing Region
spoofingRegion_logic = (xGrid >= mean_rx_power+3) & (yGrid > (mean_SBAS_cn0 + 3) - (xGrid - mean_rx_power - 3)) & (yGrid > 26) ...
    | (xGrid == mean_rx_power) & (yGrid > mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power-1) & (yGrid > mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power-2) & (yGrid > mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power+1) & (yGrid > mean_SBAS_cn0+6) ...
    | (xGrid == mean_rx_power+2) & (yGrid > mean_SBAS_cn0+6);
spoofingRegion = [xGrid(spoofingRegion_logic),yGrid(spoofingRegion_logic)];

% Plotting
figure; hold on;

% Plot each region as 1x1 square boxes
for k = 1:size(nominalRegion,1)
    x = nominalRegion(k,1);
    y = nominalRegion(k,2);
    rectangle('Position', [x-0.5, y-0.5, 1, 1], 'FaceColor', [0.6, 1, 0.6], 'EdgeColor', 'none');  % light blue
end

for k = 1:size(blockedRegion,1)
    x = blockedRegion(k,1);
    y = blockedRegion(k,2);
    rectangle('Position', [x-0.5, y-0.5, 1, 1], 'FaceColor', [0.8, 0.8, 0.8], 'EdgeColor', 'none');  % orange
end

for k = 1:size(errorRegion,1)
    x = errorRegion(k,1);
    y = errorRegion(k,2);
    rectangle('Position', [x-0.5, y-0.5, 1, 1], 'FaceColor', [0.95, 0.85, 0.4], 'EdgeColor', 'none');  % red
end

for k = 1:size(jammingRegion,1)
    x = jammingRegion(k,1);
    y = jammingRegion(k,2);
    rectangle('Position', [x-0.5, y-0.5, 1, 1], ...
              'FaceColor', [1, 0.6, 0.6], ...  % Light red
              'EdgeColor', 'none');
end

for k = 1:size(spoofingRegion,1)
    x = spoofingRegion(k,1);
    y = spoofingRegion(k,2);
    rectangle('Position', [x-0.5, y-0.5, 1, 1], ...
              'FaceColor', [0.85, 0.75, 0.95], ...  % light blue
              'EdgeColor', 'none');
end

hline = plot(-200:-50, 26.5 * ones(1, length(-200:-50)), 'k-', 'LineWidth', 2, 'DisplayName', 'Signal Loss');


% Add legend using dummy patches
legend_handles = [
    patch(NaN, NaN, [0.6, 1, 0.6]),   % light green
    patch(NaN, NaN, [0.8, 0.8, 0.8]),   % gray
    patch(NaN, NaN, [0.95, 0.85, 0.4]),    % yellow
    patch(NaN, NaN, [1, 0.6, 0.6]),    % Light red
    patch(NaN, NaN, [0.85, 0.75, 0.95]),    % Light purple
    hline
];

legend_labels = {
    'Nominal Region', 
    'Blocked Region', 
    'Error Region', 
    'Jamming Region', 
    'Spoofing Region', 
    'Signal Loss'  % label for the black line
};

legend(legend_handles, legend_labels, 'Location', 'northeast');


xlabel('Rx Power (dBW/Hz)');
ylabel('C/N₀ (dB-Hz)');
grid on;
ylim([25.5 51.5]);
xlim([-190.5 -140]);
set(gca, 'FontSize', 20);
hold off;

