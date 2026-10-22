function [total_LCP, total_capital_cost, total_operating_cost] = get_cost(diameter, column_height, porosity, rho_s, shaft_power, time_factor, PFAS_ads_per_year, sorbent_cost_per_kg, No_columns)

%% Initialization
run data.m 

%% Calculating Total Capital Cost (CAPEX)
volume = pi*((diameter^2)/4)*column_height;
if volume < 0.3
    volume_of_column = 0.3;
else
    volume_of_column = volume;
end

% Adsorption column cost
column_bare_cost_2001 = 10^(3.4974 + 0.4485*log10(volume_of_column) + 0.1074*(log10(volume_of_column))^2);
Fp1 = 1.25;
Fm1 = 3.11;
FBM1 = 2.25 + (1.82*Fm1*Fp1);
column_purchased_cost_2001 = FBM1*column_bare_cost_2001;
% fprintf('The purchase cost of tower is %d\n', column_purchased_cost_2001);
    
% Sorbent cost
sorbent_cost = sorbent_cost_per_kg*rho_s*volume_of_column*(1 - porosity);
% fprintf('The purchase cost of sorbent is %d\n', sorbent_cost);
    
% Pump cost
power = max(shaft_power, 1); % Ensuring floor of 1kW for correlation
pump_bare_cost_2001 = 10^(3.3892 + 0.0536*log10(power) + 0.1538*(log10(power))^2);
Fp2 = 1;
Fm2 = 2.25;
FBM2 = 1.89 + 1.35*Fm2*Fp2;
pump_purchased_cost_2001 = FBM2*pump_bare_cost_2001;
% fprintf('The purchase cost of pump is %d\n', pump_purchased_cost_2001);

% Total Bare Module Cost (Escalated to current year)
Bare_module_cost = No_columns * (column_purchased_cost_2001 + sorbent_cost + pump_purchased_cost_2001) * (c_index_cur_year/c_index_2001);

alpha_contigency = 0.4;
alpha_fee = 0.03;
Total_module_cost = Bare_module_cost * (1 + alpha_contigency + alpha_fee);
% fprintf('The total CAPEX is %d\n', Total_module_cost);

% Total Capital Investment
total_capital_cost = Total_module_cost / 0.8;
% fprintf('The TCI is %d\n', total_capital_cost);

%% Operating and Maintenance Cost (OPEX)
electricity = electricity_cost*shaft_power*0.95*365*24;
% fprintf('The total cost of electricity is %d\n', electricity);
sorbent_replacement_cost = sorbent_cost*ceil(time_factor)*(c_index_cur_year/c_index_2001);
% fprintf('The sorbent replacement cost is %d\n', sorbent_replacement_cost);

total_utilities = (electricity + sorbent_replacement_cost) * No_columns;
% fprintf('The total utilities cost is %d\n', total_utilities);

% Total annual operating cost (including labor and maintenance)
total_labour_cost = labour_cost_per_year*ceil((6.29 + (0.23*No_columns))^0.5);
total_operating_cost = (total_utilities + (2.215*total_labour_cost) + (0.146*Bare_module_cost))/(1-0.190);
% fprintf('The OPEX is %d\n', total_operating_cost);

%% Levelized Cost (LCP) - Net Present Value Method
t = 1:project_life;
discount_factors = 1 ./ (1 + interest_rate).^t;

PV_costs = total_capital_cost + sum(total_operating_cost .* discount_factors);

% PV of Mass = Discounted PFAS adsorbed from Year 2 to 25 (Year 1 is 0)
mass_by_year = ones(1, project_life) * PFAS_ads_per_year;
mass_by_year(1) = 0; % Startup year correction

PV_mass = sum(mass_by_year .* discount_factors);

% Final total levelized cost per kg PFAS adsorbed
total_LCP = PV_costs / PV_mass;
% fprintf('The Cost/kg PFAS captured is %d\n', total_LCP);

end