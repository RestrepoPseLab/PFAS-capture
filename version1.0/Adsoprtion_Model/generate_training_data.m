clear all;
clc;
format long;

% Define parameters
n = 60000;    % Target number of samples
p = 6;        % Number of input variables
n_try = 126172; % Generate more data to filter out bad velocities

% Define bounds for each variable
bounds = [
    1, 120;     % Capacity (m3/h)
    0.8, 4;     % diameter (m)
    1, 4;       % column_height (m)
    0.35, 0.5;  % porosity (-)
    1, 365;     % ads_time (days)
    0.01, 10    % Co (ppb)
];

% Generate Latin Hypercube samples (uniform [0,1])
disp('Generating samples...');
X_raw = lhsdesign(n_try, p);

% Scale samples to the specified bounds
X_potential = zeros(n_try, p);
for i = 1:p
    X_potential(:, i) = bounds(i, 1) + (bounds(i, 2) - bounds(i, 1)) .* X_raw(:, i);
end

% Filter for physical velocity constraints (2 - 15 m/h)
Q_vec = X_potential(:, 1);
D_vec = X_potential(:, 2);
Area_vec = pi .* (D_vec ./ 2).^2;
Velocity_vec = Q_vec ./ Area_vec;

% Find valid indices
valid_idx = find(Velocity_vec >= 2 & Velocity_vec <= 15);

% Check if we have enough
if length(valid_idx) < n
    error('Not enough valid samples. Increase n_try multiplier.');
end

% Select exactly n samples
X = X_potential(valid_idx(1:n), :);
disp('Samples generated and filtered for velocity constraints.');

% Preallocate outputs (4 outputs: Cost, emission, eff_con, amount_ads)
outputs = zeros(n, 4);

% Evaluate the function for each sample
disp('Starting function evaluation...');
tic;
for i = 1:n
    % Extract variables for clarity
    capacity = X(i, 1);
    diameter = X(i, 2);
    column_height = X(i, 3);
    porosity = X(i, 4);
    time = X(i, 5);
    C_o = X(i, 6);

    % Call physical model directly
    [total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o);
    outputs(i, :) = [total_LCP, emissions, PFAS_eff, PFAS_ads];
    
    % Progress update
    if mod(i, 1000) == 0
        fprintf('Progress: %.2f%% (%d/%d samples completed, %.2f seconds elapsed)\n', ...
        i/n*100, i, n, toc);
    end
end
disp('Evaluation complete.');
fprintf('Total time: %.2f seconds\n', toc);

% Combine inputs and outputs into a matrix
data = [X, outputs];

% Create variable names for CSV headers
var_names = {'capacity', 'diameter', 'column_height', 'porosity', 'ads_time', 'C_o', 'total_LCP', 'emissions', 'PFAS_eff', 'PFAS_ads'};

% Convert to table and write to CSV
T = array2table(data, 'VariableNames', var_names);
writetable(T, 'GAC_60k_training_data.csv');

% Display completion message
disp('Results saved to GAC_60k_training_data.csv');