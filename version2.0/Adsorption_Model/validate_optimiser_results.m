clear all;
clc;
format long;

% Define parameters
p = 6;

% Load data from Excel file
filename = 'pareto_results.xlsx';
T = readtable(filename);

% Extract input columns
input_cols = T(:, 1:p);
n = height(T);

% Preallocate outputs
outputs = zeros(n, 4);

% Evaluate the function solution
disp('Starting function evaluation...');
tic;
for i = 1:n
    X = table2array(input_cols(i, :));
    outputs(i, :) = detailed_model(X);
    fprintf('Progress: %.2f%% (%d/%d rows completed, %.2f seconds elapsed)\n', ...
    i/n*100, i, n, toc);
end
disp('Evaluation complete.');
fprintf('Total time: %.2f seconds\n', toc);

% Create a new table for outputs
output_names = {'total_LCP', 'emissions', 'PFAS_eff', 'PFAS_ads'};
newTable = array2table(outputs, 'VariableNames', output_names);

% Adjust names to avoid conflicts with existing columns in T
existing_names = T.Properties.VariableNames;
for j = 1:length(output_names)
    base_name = output_names{j};
    new_name = base_name;
    suffix = 1;
    while ismember(new_name, existing_names)
        new_name = sprintf('%s_%d', base_name, suffix);
        suffix = suffix + 1;
    end
    newTable.Properties.VariableNames{j} = new_name;
end

% Append the new table to the original T
T = [T, newTable];

% Write the updated table back to a new Excel file
output_filename = 'validate_pareto_results.xlsx';
writetable(T, output_filename);

% Display completion message
disp(['Results saved to ' output_filename]);

% Physics Model
function y = detailed_model(X)
capacity = X(1);
diameter = X(2);
column_height = X(3);
porosity = X(4);
time = X(5);
C_o = X(6);
rho_s = X(7);
dp = X(8);
qm1 = X(9);
kl1 = X(10);
sorbent_cost_per_kg = X(11);
[total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, qm1, kl1, sorbent_cost_per_kg);
y = [total_LCP, emissions, PFAS_eff, PFAS_ads];
end