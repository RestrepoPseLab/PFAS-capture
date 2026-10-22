%% Process Parameters
max_capacity_value = 120; %m3/h
operating_pressure =1.01325; %operating pressure [Bar]
rho_f = 1000; %density of the fluid [kg/m3]
mui_f = 1.004; %kinematic viscosity[mm^2/s]
MM1 = 414.07; %molar mass of component 1 [g/mol]

%% Isotherm Parameters
% qm1 = 0.56995;    %saturation loading for component 1 [mol/kg]
% kl1 = 17.515;  %thermodynamic adsorption parameter of component 1 [m^3/mol]

%% Bed Properties and Paramters
% rho_s = 500; %bulk density [kg/m3]
% dp = 0.002;  %particle diameter [m]
Dm = 5.46*10^-10;  %diffusivity [m^2/s]

%% Other Paramters
project_life = 25; % years
interest_rate = 0.1; % fraction

c_index_cur_year = 850;   %cost index in current year (March, 2026)
c_index_2001 = 394.3;       %cost index in reference year

electricity_cost = 0.1644; % electricity cost [$/kWh]
labour_cost_per_year = 100000; % labour cost [$/year/person]
% sorbent_cost_per_kg = 2; % cost of sorbent [$/kg]

co2_emi  = 0.48; %electricity co2 emissions [kg CO2/kWh]