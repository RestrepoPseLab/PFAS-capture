clear all;
clc;
format longG

% Params/Variable
capacity = 10;
diameter = 0.800135863;
column_height = 2.458277015;
porosity = 0.499999007;
time = 20.66148158;
C_o = 0.5;

[total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o);
fprintf('The total_LCP is %d\n', total_LCP);
fprintf('The emissions is %d\n', emissions);
fprintf('The PFAS_eff is %d\n', PFAS_eff);
fprintf('The PFAS_ads is %d\n', PFAS_ads);
