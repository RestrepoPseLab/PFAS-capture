% --- CALIBRATION SCRIPT ---
n_test = 100000; % A quick test batch
p = 6;
bounds = [1, 120; 0.8, 4; 1, 4; 0.35, 0.5; 1, 365; 0.01, 10];

% Generate test samples
X_test = lhsdesign(n_test, p);

% Scale
Q_test = bounds(1,1) + (bounds(1,2)-bounds(1,1)) .* X_test(:,1);
D_test = bounds(2,1) + (bounds(2,2)-bounds(2,1)) .* X_test(:,2);

% Check Physics
Area_test = pi .* (D_test./2).^2;
V_test = Q_test ./ Area_test;
valid_count = sum(V_test >= 2 & V_test <= 15);

% Calculate Yield
yield_rate = valid_count / n_test;
optimal_oversample = 1 / yield_rate;

fprintf('Yield Rate: %.2f%%\n', yield_rate * 100);
fprintf('Optimal Oversample Factor: %.2f\n', optimal_oversample);
fprintf('For 60,000 samples, set n_try = %d\n', ceil(60000 * optimal_oversample * 1.05));