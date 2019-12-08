function [R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load)
	for g =1:length(ch1_data)
		if ch1_data(g) == 0.00000000
			ch1_data(g) = 0.00000001;
			end
		end
R_mem1 = abs(((ch3_data-ch1_data)./(ch1_data))*R_load);