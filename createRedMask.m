function mask = createRedMask(hue, sat, val)
    % Define HSV ranges for red
    lower_red1_hue = 0/360;    upper_red1_hue = 20/360;
    lower_red1_sat = 40/255;   upper_red1_sat = 1.0;
    lower_red1_val = 40/255;   upper_red1_val = 1.0;

    lower_red2_hue = 330/360;  upper_red2_hue = 1.0;
    lower_red2_sat = 60/255;   upper_red2_sat = 1.0;
    lower_red2_val = 60/255;   upper_red2_val = 1.0;

    % Create masks for each red range
    mask1 = (hue >= lower_red1_hue & hue <= upper_red1_hue) & ...
            (sat >= lower_red1_sat & sat <= upper_red1_sat) & ...
            (val >= lower_red1_val & val <= upper_red1_val);

    mask2 = (hue >= lower_red2_hue & hue <= upper_red2_hue) & ...
            (sat >= lower_red2_sat & sat <= upper_red2_sat) & ...
            (val >= lower_red2_val & val <= upper_red2_val);

    % Combine both masks
    mask = mask1 | mask2;
end
