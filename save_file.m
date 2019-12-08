function save_file(str1,foldername,measurementnum,x,ch1_data,ch3_data,R_mem1,R_load)
%This function saves the waveform into .txt file
U_mem = ch3_data - ch1_data;
I_circuit = ch1_data/R_load;
dlmwrite(strcat(foldername,'\',measurementnum,str1,'.txt'),[x,ch1_data,ch3_data,R_mem1,U_mem,I_circuit],'delimiter','\t','precision','%.8f');
