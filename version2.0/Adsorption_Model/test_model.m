clear all;
clc;
format longG

% Params/Variable
capacity = 115;
diameter = 1.501393695;
column_height = 2.349383223;
porosity = 0.403194515;
time = 6.066576972;
C_o = 0.5;
rho_s = 500;
dp = 2e-3;
qm1 = 0.56995;
kl1 = 17.515;
sorbent_cost_per_kg = 2;

[total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, qm1, kl1, sorbent_cost_per_kg);
fprintf('The total_LCP is %d\n', total_LCP);
fprintf('The emissions is %d\n', emissions);
fprintf('The PFAS_eff is %d\n', PFAS_eff);
fprintf('The PFAS_ads is %d\n', PFAS_ads);
