function [total_LCP, emissions, PFAS_eff, PFAS_ads] = adsorption_model(capacity, diameter, column_height, porosity, time, C_o)

run data.m
    try
    [emissions, PFAS_eff, time_factor, PFAS_ads, PFAS_ads_per_year, shaft_power] = comsol_model(capacity, diameter, column_height, porosity, time, C_o);
    [total_LCP, ~, ~] = get_cost(diameter, column_height, porosity, shaft_power, time_factor, PFAS_ads_per_year);
    catch
        total_LCP = nan;
        emissions = nan;
        PFAS_eff = nan;
        PFAS_ads = nan;
    end
end
