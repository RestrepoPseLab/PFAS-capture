function [emissions, PFAS_eff, time_factor, PFAS_ads, PFAS_ads_per_year, shaft_power] = comsol_model(capacity, diameter, column_height, porosity, time, C_o)

run data.m
run Model.m

model.param.set('v', sprintf('%d[m^3/h]/(pi*(D_i^2)/4)',capacity));
model.param.set('L', sprintf('%d[m]',column_height));
model.param.set('D_i', sprintf('%d[m]',diameter));
model.param.set('rho_s', sprintf('%d[kg/m^3]/(1-eb)',rho_s));
model.param.set('eb', sprintf('%d',porosity));
model.param.set('rp', 'dp/2');
model.param.set('dp', sprintf('%d[m]',dp));
model.param.set('Dm', sprintf('%d[m^2/s]',Dm));
model.param.set('mui', sprintf('%d[mm^2/s]',mui_f));
model.param.set('Co', sprintf('%d*1e3*1e-9[g/L]/MM1',C_o));
model.param.set('MM1', sprintf('%d[g/mol]',MM1));
model.param.set('Dl', '(2*v*rp)*(0.5+(20/(Re*Sc)))');
model.param.set('q_sat', sprintf('%d[mol/kg]',qm1), 'saturation value on q in L model');
model.param.set('b_o1', sprintf('%d[m^3/mol]',kl1), 'thermodynamic adsorption parameter');
model.param.set('Sc', 'mui/Dm');
model.param.set('Sh', '(1.09/eb)*(Re^0.33)*(Sc^0.33)');
model.param.set('Re', '(v*dp*eb)/mui');
model.param.set('k', '(Dm/dp)*Sh');
model.param.set('a', '(3/(dp/2))');
model.param.set('K', 'k*a');


model.study('std1').feature('time').set('tunit', 'd');

if time < 10
    model.study('std1').feature('time').set('tlist', sprintf('range(0,0.1,%d)',time));
else
    model.study('std1').feature('time').set('tlist', sprintf('range(0,1,%d)',time));
end

model.study('std1').run();

% Define positions (column_height in meters, COMSOL in cm)
z_inlet  = 0;
z_outlet = column_height * 100;  % m to cm

pfas_eff = mphinterp(model, 'c', 'coord', [z_outlet], 'dataset', 'dset1', 'solnum', 'end');

% Extract time vector
time_ads = mphglobal(model, 't', 'dataset', 'dset1');

% Interpolate concentrations over time
pfas_in  = mphinterp(model, 'c', 'coord', [z_inlet],  'dataset', 'dset1', 't', time_ads);
pfas_out = mphinterp(model, 'c', 'coord', [z_outlet], 'dataset', 'dset1', 't', time_ads);

% Compute average inlet concentration
avg_pfas_in = mean(pfas_in);

% Apply correction: cap any outlet value exceeding average inlet concentration
% This prevents unphysical overshoot due to numerical dispersion/artifacts
pfas_out_corrected = pfas_out;
pfas_out_corrected(pfas_out > avg_pfas_in) = avg_pfas_in;

% Now compute integrals using the corrected outlet data
PFAS_in  = trapz(time_ads, pfas_in);
PFAS_out = trapz(time_ads, pfas_out_corrected);

% fprintf('The PFAS_in is %d\n', PFAS_in);
% fprintf('The PFAS_out is %d\n', PFAS_out);

time_factor = (1*365)/time;
fprintf('The No of batch(es) is/are %d\n', time_factor);

% calculate velocity
velocity = capacity/(pi*(diameter^2)/4);

PFAS_ads = (pi*(diameter^2)/4)*(velocity*24)*(PFAS_in-PFAS_out)*MM1*1e-3/86400;
% fprintf('The PFAS_ads per batch is %d\n', PFAS_ads);

PFAS_ads_per_year = PFAS_ads*time_factor;
% fprintf('The PFAS_ads per year is %d\n', PFAS_ads_per_year);

shaft_power1 = ((velocity*(pi*(diameter^2)/4))*rho_f*9.81*column_height)/((3.6*1e6)*0.75);

if shaft_power1 < 1
    shaft_power = 1;
else
    shaft_power = shaft_power1;
end

% fprintf('The shaft power is %d\n', shaft_power);

emissions = co2_emi*shaft_power1;
% fprintf('The emissions is/are %d\n', emissions);
PFAS_eff = pfas_eff;
% fprintf('The eff_conc is/are %d\n', PFAS_eff);

end