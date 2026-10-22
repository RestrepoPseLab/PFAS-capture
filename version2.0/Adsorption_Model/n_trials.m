% --- CALIBRATION SCRIPT ---
run data.m
n_test = 388167; % A quick test batch
p = 11;
bounds = [10, 5000; 0.8, 4; 1, 4; 0.35, 0.5; 30, 365*5; 0.001, 10; 500, 2000; 0.01e-3, 2e-3; 0.001, 10; 1, 10000; 1, 2000];

% Generate test samples
X_test = lhsdesign(n_test, p);

% Scale
Q_test = bounds(1,1) + (bounds(1,2)-bounds(1,1)) .* X_test(:,1);
D_test = bounds(2,1) + (bounds(2,2)-bounds(2,1)) .* X_test(:,2);

% Check Physics
Area_test = pi .* (D_test./2).^2;

No_colums = ceil(Q_test / max_capacity_value);
Q_vec_test = Q_test ./ No_colums;

V_test = Q_vec_test ./ Area_test;
valid_count = sum(V_test >= 2 & V_test <= 15);

% Calculate Yield
yield_rate = valid_count / n_test;
optimal_oversample = 1 / yield_rate;

fprintf('Yield Rate: %.2f%%\n', yield_rate * 100);
fprintf('Optimal Oversample Factor: %.2f\n', optimal_oversample);
fprintf('For 200,000 samples, set n_try = %d\n', ceil(200000 * optimal_oversample * 1.05));