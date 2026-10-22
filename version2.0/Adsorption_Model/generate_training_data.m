clear all;
clc;
format long;
run data.m

% Define parameters
n = 200000;    % Target number of samples
p = 11;        % Number of input variables
n_try = 752800; % Generate more data to filter out bad velocities

% Define bounds for each variable
bounds = [
    10, 5000;     % Capacity (m3/h)
    0.8, 4;      % diameter (m)
    1, 4;        % column_height (m)
    0.35, 0.5;   % porosity (-)
    30, 365*5;      % ads_time (days)
    0.001, 10;    % Co (ppb)
    500, 2000;   % rho_s (kg/m3)
    0.3e-3, 2.5e-3;     % particle diameter m
    0.001, 10;     % q_max (mol/kg)
    1, 10000;      % kl1 (m3/mol)
    1, 2000       % Sorbent_cost ($/kg)
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
Q_total_vec = X_potential(:, 1);
No_colums = ceil(Q_total_vec / max_capacity_value);
Q_vec = Q_total_vec ./ No_colums;
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

% Save the input features before running the model
input_var_names = {'capacity', 'diameter', 'column_height', 'porosity', 'ads_time', 'C_o', 'rho_s', 'dp', 'qm1', 'kl1', 'sorbent_cost_per_kg'};
T_inputs = array2table(X, 'VariableNames', input_var_names);
writetable(T_inputs, 'input_features_only.csv');
disp('Input features saved to input_features_only.csv');

% Preallocate outputs (4 outputs: Cost, emission, eff_con, amount_ads)
outputs = zeros(n, 4);

% Prepare the streaming CSV for running results
all_var_names = {'capacity', 'diameter', 'column_height', 'porosity', 'ads_time', 'C_o', 'rho_s', 'dp', 'qm1', 'kl1', 'sorbent_cost_per_kg', 'total_LCP', 'emissions', 'PFAS_eff', 'PFAS_ads'};
streaming_filename = 'running_results_stream.csv';
fid = fopen(streaming_filename, 'w');
% Write the header row to the file
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', all_var_names{:});


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
    rho_s = X(i,7);
    dp = X(i,8);
    qm1 = X(i,9);
    kl1 = X(i,10);
    sorbent_cost_per_kg = X(i,11);
    
    % Call physical model directly
    [total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, qm1, kl1, sorbent_cost_per_kg);
    outputs(i, :) = [total_LCP, emissions, PFAS_eff, PFAS_ads];

    % Append the current row to the CSV immediately
    fprintf(fid, '%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n', ...
            capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, ...
            qm1, kl1, sorbent_cost_per_kg, total_LCP, emissions, PFAS_eff, PFAS_ads);
    % =====================================================================

    % Progress update
    if mod(i, 1000) == 0
        fprintf('Progress: %.2f%% (%d/%d samples completed, %.2f seconds elapsed)\n', ...
        i/n*100, i, n, toc);
    end
end

% Close the streaming file now that the loop is finished
fclose(fid);

disp('Evaluation complete.');
fprintf('Total time: %.2f seconds\n', toc);

% Combine inputs and outputs into a matrix (Optional, since we saved the stream, but good for final clean dataset)
data = [X, outputs];

% Convert to table and write to CSV
T = array2table(data, 'VariableNames', all_var_names);
writetable(T, 'ALLMAT_200k_training_data.csv');

% Display completion message
disp('Final results saved to ALLMAT_200k_training_data.csv');