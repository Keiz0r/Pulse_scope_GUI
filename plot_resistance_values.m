function plot_values (runnum,maxfiles)
%plots data from measurements. Input amount of files to plot
foldername = 'Resistance_measurement';
str1 = '_func1_RUN';
runnum_init = runnum;
%maxfiles = 40;
temp_fig = figure(2);
temp_fig.Name = 'measurements';
temp_fig.NumberTitle = 'off';
q = axes('Parent',temp_fig,'Color',[0.7,0.7,0.7]);
hold on
while runnum <= maxfiles
	A=importdata(strcat(foldername,'\',num2str(runnum),str1,'.txt'));
	plot(q,A(:,2));
	runnum = runnum+1;
	end
legend_string = num2str((linspace(runnum_init,maxfiles,maxfiles)')*0.05+0.15);
legend(q,legend_string)