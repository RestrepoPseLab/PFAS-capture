clear all;
clc;
format long;
run data.m

% Define parameters
n = 200000;    % Target number of samples

% 1. Load the exact inputs you generated in the original run
disp('Loading previously generated inputs from input_features_only.csv...');
T_inputs = readtable('input_features_only.csv');
X = table2array(T_inputs);
disp('Inputs loaded successfully.');

% 2. Figure out exactly where the script stopped
streaming_filename = 'running_results_stream.csv';
disp('Checking progress from the stream file...');
T_done = readtable(streaming_filename);
n_completed = height(T_done); % Number of rows already processed (excluding header)
start_idx = n_completed + 1;

if start_idx > n
    disp('All 200,000 samples are already completed!');
    return;
end

fprintf('Found %d completed rows. Resuming from iteration %d...\n', n_completed, start_idx);

% 3. Open the file in APPEND mode ('a') so it doesn't overwrite old data
fid = fopen(streaming_filename, 'a');

% Evaluate the function for the REMAINING samples
disp('Starting function evaluation for remaining samples...');
tic;
for i = start_idx:n
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

    % Append the current row to the CSV immediately
    fprintf(fid, '%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n', ...
            capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, ...
            qm1, kl1, sorbent_cost_per_kg, total_LCP, emissions, PFAS_eff, PFAS_ads);
    % =====================================================================

    % Progress update
    if mod(i, 1000) == 0
        fprintf('Progress: %.2f%% (%d/%d samples completed, %.2f seconds elapsed on this resume)\n', ...
        i/n*100, i, n, toc);
    end
end

% Close the streaming file now that the loop is finished
fclose(fid);

disp('Evaluation complete.');
fprintf('Total time for this resume session: %.2f seconds\n', toc);

% 4. Combine everything into the final clean dataset
disp('Generating final ALLMAT_200k_training_data.csv...');
% Because we appended to the stream, the stream CSV now contains ALL 200k results.
% We just read it and save it as the final file.
T_final = readtable(streaming_filename);
writetable(T_final, 'ALLMAT_200k_training_data.csv');

disp('Final results saved to ALLMAT_200k_training_data.csv');