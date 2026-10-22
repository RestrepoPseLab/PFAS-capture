function [total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, qm1, kl1, sorbent_cost_per_kg)

run data.m
    try
    [emissions, PFAS_eff, time_factor, PFAS_ads, PFAS_ads_per_year, shaft_power, No_columns] = comsol_model(capacity, diameter, column_height, porosity, time, C_o, rho_s, dp, qm1, kl1);
    [total_LCP, ~, ~] = get_cost(diameter, column_height, porosity, rho_s, shaft_power, time_factor, PFAS_ads_per_year, sorbent_cost_per_kg, No_columns);
    catch
        total_LCP = nan;
        emissions = nan;
        PFAS_eff = nan;
        PFAS_ads = nan;
    end
end
