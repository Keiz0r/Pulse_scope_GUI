function GUI
	%v.1.10
	
	%Savedfiles structire: 	x,ch1_data,ch3_data,R_mem1,U_mem,I_circuit
	%Parameters.txt structire: 	Pulse_width,rise_fall_time,slope,SET,RESET,R_load
	
%- - - - - - - - - - GUI construct - - - - - - - - - - 	
	f = figure('Name','Memristor measurement Tool','NumberTitle','off','MenuBar','none','Units','normal','Position',[0,.042,1,.94],...
	'Color',[0.7,0.7,0.7],'CloseRequestFcn',@my_closereq,'KeyPressFcn',@keydetect);
	ax = axes('Parent',f,'OuterPosition',[0.3,0,0.7,1],'Color','k','XGrid','on','YGrid','on','GridColorMode','manual',...
	'NextPlot','replacechildren','GridColor','w','XMinorGrid','on','YMinorGrid','on','MinorGridColor','w');
	ax.Title.String = 'Scope data';
	ax.XLabel.String = 'Time, us';
	ax.YLabel.String = 'Voltage, V';
	plot(ax,linspace(0,1),cos(linspace(0,1)),'y',linspace(0,1),sin(linspace(0,1)),'c',linspace(0,1),tan(linspace(0,1)),'m');
	lgd = legend(ax,{'Load Resistor Voltage','Input Voltage','Memristor Voltage'},'TextColor','w');
	legend(ax,'boxoff');
	ax2 = axes('Parent',f,'OuterPosition',[.0,.12,0.35,.4],'Color','k','XGrid','on','YGrid','on','GridColorMode','manual',...
	'NextPlot','replacechildren','GridColor','w','XMinorGrid','on','YMinorGrid','on','MinorGridColor','w');	%,'ylim',[1,(10^7)],'Yscale','log'
	ax2.Title.String = 'Device I-V';
	
	Ok_prompt = figure(3);
	Ok_prompt.MenuBar = 'none';
	Ok_prompt.Units = 'normal';
	Ok_prompt.Position = [0.4,0.5,0.2,0.1];
	Ok_prompt.Name = 'Current increase necessary';
	Ok_prompt.NumberTitle = 'off';
	Ok_prompt.Visible = 'off';
	
	Parameters = uipanel('Parent',f,'Title','Pulse parameters','FontSize',12,'Position',[.01 .82 .3 .18],'BackgroundColor',[0.7 0.7 0.7]);
	Actions = uipanel('Parent',f,'Title','Actions','FontSize',12,'Position',[.03 .74 .25 .08],'BackgroundColor',[0.7 0.7 0.7]);
	OUTPUTBOX_outline = uipanel('Parent',f,'Title','Output box','FontSize',12,'Units','normal','Position',[.45,.02,.42,.05],'BackgroundColor',[0.7 0.7 0.7]);

	
		%EDITABLE VALUES
	SET_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','1','FontSize',12,'Position',[0.016,0.62,0.23,0.2]);
	SET_value.Callback = @retrieve_SET;
	SET_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','SET value','FontSize',12,'Position',[0.016,0.84,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	READ_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','0.15','FontSize',12,'Position',[0.262,0.62,0.23,0.2]);
	READ_value.Callback = @retrieve_READ;
	READ_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','READ value','FontSize',12,'Position',[0.262,0.84,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	RESET_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','-1.5','FontSize',12,'Position',[0.508,0.62,0.23,0.2]);
	RESET_value.Callback = @retrieve_RESET;
	RESET_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','RESET value','FontSize',12,'Position',[0.508,0.84,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	
	rise_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','0.150','FontSize',12,'Position',[0.754,0.62,0.23,0.2]);
	rise_value.Callback = @retrieve_rise_fall_time;
	rise_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','Rise time','FontSize',12,'Position',[0.754,0.84,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	
	Width_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','1','FontSize',12,'Position',[0.016,0.14,0.23,0.2]);
	Width_value.Callback = @retrieve_Width;
	Width_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','Pulse width','FontSize',12,'Position',[0.016,0.36,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	scope_timescale_value = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','0.2','FontSize',12,'Position',[0.262,0.14,0.23,0.2]);
	scope_timescale_value.Callback = @retrieve_scope_timescale;
	scope_timescale_value_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','Scope Timescale','FontSize',12,'Position',[0.262,0.36,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	fileno = uicontrol('Parent',Parameters,'Style','edit','Units','normal','string','1','FontSize',12,'Position',[0.754,0.14,0.23,0.2]);
	fileno.Callback = @retrieve_fileno;
	fileno_text = uicontrol('Parent',Parameters,'Style','text','Units','normal','String','File number','FontSize',12,'Position',[0.754,0.36,0.23,0.16],'BackgroundColor',[0.7 0.7 0.7]);
	
	Resistance_value = uicontrol('Parent',f,'Style','edit','Units','normal','string','100000','FontSize',12,'Position',[0.33,0.02,0.05,0.03]);
	Resistance_value.Callback = @retrieve_Resistance;
	Resistance_text = uicontrol('Parent',f,'Style','text','Units','normal','String','Load Resistance','FontSize',12,'Position',[0.33,0.05,0.05,0.04],'BackgroundColor',[0.7 0.7 0.7]);
	
	
	OUTPUTBOX = uicontrol('Parent',OUTPUTBOX_outline,'Style','edit','Units','normal','String','Hardware setup is in process. Please wait.','FontSize',10,'Position',[.01,.1,.98,.9]);

		%BUTTONS
	set_button = uicontrol('Parent',Actions,'String','SET(Q)','Units','normal','FontSize',12,'Position',[0.016,0.1,0.23,1],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	set_button.Callback = @setbutton;
	read_button = uicontrol('Parent',Actions,'String','READ(W)','Units','normal','FontSize',12,'Position',[0.262,0.1,0.23,1],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	read_button.Callback = @readbutton;
	reset_button = uicontrol('Parent',Actions,'String','RESET(E)','Units','normal','FontSize',12,'Position',[0.508,0.1,0.23,1],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	reset_button.Callback = @resetbutton;
	nread_button = uicontrol('Parent',Actions,'String','NREAD','Units','normal','FontSize',12,'Position',[0.754,0.1,0.23,1],'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	nread_button.Callback = @nreadbutton;

	Square_to_Triang_button = uicontrol('Parent',f,'Style','togglebutton','String','Square','Units','normal','FontSize',12,'Position',[0.286,0.75,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Square_to_Triang_button.Callback = @square_to_triang;
	
	
	Connect_button = uicontrol('Parent',f,'Style','togglebutton','String','Instruments disconnected','FontSize',14,'Units','normal','Position',[.05,.04,.25,.08],...
	'Backgroundcolor','r','KeyPressFcn',@keydetect);
	Connect_button.Callback = @connect_instr;

		%FUNCTIONAL BUTTONS
	Func1_button = uicontrol('Parent',f,'Style','togglebutton','String','R(V)','Units','normal','FontSize',12,'Position',[0.016,0.6,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Func1_button.Callback = @function1_button;

	Func2_button = uicontrol('Parent',f,'Style','togglebutton','String','Unst Fil','Units','normal','FontSize',12,'Position',[0.076,0.6,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Func2_button.Callback = @unstable_filament_timing;
	
	Func3_button = uicontrol('Parent',f,'Style','togglebutton','String','Stats','Units','normal','FontSize',12,'Position',[0.136,0.6,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Func3_button.Callback = @Stat_cycle;
	
	Func4_button = uicontrol('Parent',f,'Style','togglebutton','String','Stats low R','Units','normal','FontSize',12,'Position',[0.136,0.655,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	Func4_button.Callback = @Stat_cycle_low_res;
	
	
	RUNSTOP_button = uicontrol('Parent',f,'Style','togglebutton','String','RUN','Units','normal','FontSize',12,'Position',[0.216,0.6,0.05,0.05],...
	'Backgroundcolor','k','Foregroundcolor','w','KeyPressFcn',@keydetect);
	RUNSTOP_button.Callback = @RUNSTOP_function;
	
	%- - - - - - - - - - Parameters definition - - - - - - - - - -
	max_cyclenum = 1;       %number of measurements
	folder_name = 'C:\Users\Ruzin\Documents\MATLAB\savedfiles';
	do_analysis = 1;        %yes/no

	%- - - - - - - - - - generator constants description - - - - - - - - - -
	Pulse_width = '1';
	Pulse_width_units = 'us';                                         %s,ms,us,ns
	scope_timescale = 0.2;                                            %Scope timescale uses same units as defined in Pulse_width_units
	SET1 = 1;
	SET2 = SET1;
	RESET1 = -1.5;                                                    %if <-3.6 problems on next read start. look into generator issues when switching from high negative voltages into positive
	RESET2 = RESET1;
	READ = '0.15';
	setcommand = (':VOLT1:HIGH');
	SET = num2str(SET1);
	setvalue = strcat(setcommand,32,SET);
	resetcommand = (':VOLT1:LOW');
	RESET = num2str(RESET1);
	resetvalue = strcat(resetcommand,32,RESET);
	readvalue = strcat(setcommand,32,READ);
	%- - - - - - - - - - Equipment setup - - - - - - - - - - 
	obj1 = gpib('AGILENT', 32, 11);
	obj2 = gpib('AGILENT', 32, 12);
	fclose([obj1 obj2]);           %Necessary for wrong closure of the program


	[ch1_gain,ch2_gain,ch3_gain,ch4_gain,ch1_offset,ch2_offset,ch3_offset,ch4_offset,ch1_attn,ch2_attn,ch3_attn,ch4_attn,data_points,x] = Scope_setup(obj1,Pulse_width,Pulse_width_units,scope_timescale);
	Generator_setup(obj2,Pulse_width,Pulse_width_units)
	OUTPUTBOX.String = 'Equipment setup succesful ';
	fprintf('Equipment setup succesful \n');
	
	real_data_points = data_points/2;
	index2 = 0.04*(real_data_points-2)+((real_data_points-2)/(10*scope_timescale))*str2double(Pulse_width);	%indexes for analysis
	index1 = index2-((real_data_points-2)/10);		%indexes for analysis
	lastoperation =1;						%for analysis
	
	
	%- - - - - - - - - - Folder creation - - - - - - - - - - 
	if ~exist(folder_name, 'dir')
		mkdir(folder_name);
	end
	
	R_load = 100000; %100kOhm
	filenam = strcat(folder_name,'\Parameters.txt');
	if exist(filenam) == 2
		filenam = strcat(folder_name,'\Parameters2.txt');
		end
	fid3 = fopen(filenam, 'w+');
	fid3 = fclose(fid3);
	rise_fall_time = '0.150';
	%



	measurementnum=1;
	slope = '- - -';
%- - - - - - - - - - - - Functions - - - - - - - - - - - -

    function setbutton(src,event)
		%- - - - - - - - - - SET - - - - - - - - - -
		[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = XSET_PROCESS(obj1,obj2,setvalue);                %See function SET_PROCESS
		ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
		slope = num2str(str2double(SET)/str2double(rise_fall_time));
		ylim(ax,[-0.5 4.5]);
		plot(ax,x,ch1_data,'y',x,ch3_data,'c',x,ch3_data-ch1_data,'m');
		plot(ax2,(ch3_data(1:ceil(end/2))-ch1_data(1:ceil(end/2))),(ch1_data(1:ceil(end/2))/R_load),'y',(ch3_data(ceil(end/2):end)-ch1_data(ceil(end/2):end)),(ch1_data(ceil(end/2):end)/R_load),'w');
		text(0.01,0.98,strcat('slope',32,slope,32,'V/us'),'Interpreter','none','Units','normalized','Backgroundcolor','none','FontUnits','normalized','FontSize',0.03,'color','w','parent',ax)
		save_file('_SET',folder_name,num2str(measurementnum),x,ch1_data,ch3_data,R_mem1,R_load);
		OUTPUTBOX.String = strcat('SET no',32,num2str(measurementnum));
		fprintf('SET no %d\n',measurementnum);
		%pause(1)
		save_parameters_file
		measurementnum = measurementnum +1;
		fileno.String = num2str(measurementnum);
		lastoperation = 1;
		end
	
	function readbutton(src,event)
		%- - - - - - - - - - READ11 - - - - - - - - - -
		[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);                        %See function READ1_PROCESS
		ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
		slope = '- - -';
		ylim(ax,[-0.02 0.4]);
		plot(ax,x,ch1_data,'y',x,ch3_data,'c',x,ch3_data-ch1_data,'m');
		plot(ax2,(ch3_data(1:ceil(end/2))-ch1_data(1:ceil(end/2))),(ch1_data(1:ceil(end/2))/R_load),'y',(ch3_data(ceil(end/2):end)-ch1_data(ceil(end/2):end)),(ch1_data(ceil(end/2):end)/R_load),'w');
		save_file('_READ1',folder_name,num2str(measurementnum),x,ch1_data,ch3_data,R_mem1,R_load);           %change read1 and 2 according to lastoperation     (IMPROVEMENT SUGGESTION)
		OUTPUTBOX.String = strcat('READ1 no ',num2str(measurementnum));
		fprintf('READ1 no %d\n',measurementnum);
%		pause(1)
			if do_analysis== 1 & lastoperation == 1
				failread_trigger = fail_check(ch1_data,ch3_data,'READ1',index1,index2);
				if failread_trigger == 1
					OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. SET Failed. The device is in High resistive state');
					else OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. SET Succesful. The device is in Low resistive state');
					end
				elseif do_analysis== 1 & lastoperation == 0
					failread_trigger = fail_check(ch1_data,ch3_data,'READ2',index1,index2);
					if failread_trigger == 1
					OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. RESET Failed. The device is in Low resistive state');
					else OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. RESET Succesful. The device is in High resistive state');
					end
				end
		save_parameters_file
		measurementnum = measurementnum +1;
		fileno.String = num2str(measurementnum);
		end
	
	function resetbutton(src,event)
		%- - - - - - - - - - RESET - - - - - - - - - -
		[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = XRESET_PROCESS(obj1,obj2,resetvalue);             %See function RESET_PROCESS
		ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
		slope = num2str(str2double(RESET)/str2double(rise_fall_time));
		ylim(ax,[-4.5 0.5]);
		plot(ax,x,ch1_data,'y',x,ch3_data,'c',x,ch3_data-ch1_data,'m');
		plot(ax2,(ch3_data(1:ceil(end/2))-ch1_data(1:ceil(end/2))),(ch1_data(1:ceil(end/2))/R_load),'y',(ch3_data(ceil(end/2):end)-ch1_data(ceil(end/2):end)),(ch1_data(ceil(end/2):end)/R_load),'w');
		text(0.01,0.98,strcat('slope',32,slope,32,'V/us'),'Interpreter','none','Units','normalized','Backgroundcolor','none','FontUnits','normalized','FontSize',0.03,'color','w','parent',ax)
		save_file('_RESET',folder_name,num2str(measurementnum),x,ch1_data,ch3_data,R_mem1,R_load);
		OUTPUTBOX.String = strcat('RESET no',32,num2str(measurementnum));
		fprintf('RESET no %d\n',measurementnum);
%		pause(1)
		save_parameters_file
		measurementnum = measurementnum +1;
		fileno.String = num2str(measurementnum);
		lastoperation = 0;
		end

	function nreadbutton(src,event)
		%- - - - - - - - - - READ11 - - - - - - - - - -
		[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = NREAD_PROCESS(obj1,obj2,readvalue);                        %See function READ1_PROCESS
		ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
		[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
		ylim(ax,[-0.2 0.02]);
		plot(ax,x,ch1_data,'y',x,ch3_data,'c');
		plot(ax2,x,R_mem1,'y');
		save_file('_NREAD',folder_name,num2str(measurementnum),x,ch1_data,ch3_data,R_mem1,R_load);           %change read1 and 2 according to lastoperation     (IMPROVEMENT SUGGESTION)
		OUTPUTBOX.String = strcat('NREAD no ',num2str(measurementnum));
		fprintf('NREAD no %d\n',measurementnum);
%		pause(1)
			if do_analysis== 1 & lastoperation == 1
				failread_trigger = fail_check(ch1_data,ch3_data,'READ2',index1,index2);
				if failread_trigger == 1
					OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. SET Failed. The device is in High resistive state');
					else OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. SET Succesful. The device is in Low resistive state');
					end
				elseif do_analysis== 1 & lastoperation == 0
					failread_trigger = fail_check(ch1_data,ch3_data,'READ1',index1,index2);
					if failread_trigger == 1
					OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. RESET Failed. The device is in Low resistive state');
					else OUTPUTBOX.String = strcat(OUTPUTBOX.String,'. RESET Succesful. The device is in High resistive state');
					end
				end
		save_parameters_file
		measurementnum = measurementnum +1;
		fileno.String = num2str(measurementnum);
		end		
		
	function square_to_triang(src,event)
		button_state = get(src,'Value');
		rise_fall_time = num2str((str2double(Pulse_width))/2);
		if button_state == 1
			fprintf(obj2, strcat(':PULS:TRAN1',32,rise_fall_time,32,Pulse_width_units));                  %Leading edge
			pause(0.1)
			fprintf(obj2, strcat(':PULS:TRAN1:TRA',32,rise_fall_time,32,Pulse_width_units));              %Trailing edge
			pause(0.1)
			OUTPUTBOX.String = 'Triangular pulse mode activated \n';
			fprintf('Triangular pulse mode activated \n');
			Square_to_Triang_button.String = 'Triang';
			else
			rise_fall_time = '0.150';
			fprintf(obj2, ':PULS:TRAN1 150 ns');                  %Leading edge
			pause(0.1)
			fprintf(obj2, ':PULS:TRAN1:TRA 150 ns');              %Trailing edge
			pause(0.1)
			OUTPUTBOX.String = 'Square pulse mode activated \n';
			fprintf('Square pulse mode activated \n');
			Square_to_Triang_button.String = 'Square';
			end
		rise_value.String = rise_fall_time;
		end
		
	function function1_button(src,event)
		%Folder creation
		if ~exist('Resistance_measurement', 'dir')
		mkdir('Resistance_measurement');
			end
		%- - - - - - - - - - Resistance_measurement cycle - - - - - - - - - -
		runnum=1;
		runnum_init=1;
		f1_voltage = 0.2;
		addition = 0.05;
		while f1_voltage <= 2.5 & get(src,'Value') == 1
			setvalue = strcat(setcommand,32,num2str(f1_voltage)); 		%INITIAL VOLTAGE
			f1_voltage = f1_voltage+addition;							%VOLTAGE STEP
			[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = SET_PROCESS(obj1,obj2,setvalue);                
			ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
			ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
			[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
			plot(ax,x,ch1_data,'y',x,ch3_data,'c');
			plot(ax2,x,R_mem1,'y');
			save_file('_func1_RUN','Resistance_measurement',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
			pause(0.01)
			OUTPUTBOX.String = strcat('func 1 RUN no',32,num2str(runnum));
			fprintf('func 1 RUN no %d\n',runnum);
			runnum = runnum+1;
			end
		setvalue = strcat(setcommand,32,SET);							%RESET TO INITIAL VOLTAGE
		plot_resistance_values(runnum_init,runnum-1)
		end

	function unstable_filament_timing(src,event)
		%Folder creation
		if ~exist('Unstable_filament', 'dir')
		mkdir('Unstable_filament');
			end
		runnum=1;
		f1_voltage = 1;
		addition = 0.25;
		amount_of_noSET = 0;
		while f1_voltage <=4 & get(src,'Value') == 1
			setvalue = strcat(setcommand,32,num2str(f1_voltage)); 		%INITIAL VOLTAGE
			[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = SET_PROCESS(obj1,obj2,setvalue);
			ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
			ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
			[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
			plot(ax,x,ch1_data,'y',x,ch3_data,'c');
			plot(ax2,x,R_mem1,'y');
			save_file('_Unstable_filament_timing_RUN','Unstable_filament',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
			pause(0.01)
			OUTPUTBOX.String = strcat('Unstable filament timing RUN no',32,num2str(runnum));
			fprintf('Unstable filament timing RUN no %d\n',runnum);
			failread_trigger = fail_check(ch1_data,ch3_data,'SET',index1,index2);
			if failread_trigger == 1
				tic												%timing
				runnum=1;
				while get(src,'Value')
					%- - - - - - - - - - READ - - - - - - - - - -
					[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);
					ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
					plot(ax,x,ch1_data,'y',x,ch3_data,'c');
					plot(ax2,x,R_mem1,'y');
					failread_trigger = fail_check(ch1_data,ch3_data,'READ1',index1,index2);
					if failread_trigger == 1
						toc										%timing
						save_file('_READ','Unstable_filament',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
						OUTPUTBOX.String = strcat('Unstable filament is GONE. READ no',32,num2str(runnum));
						fprintf('Unstable filament is GONE. READ no %d\n',runnum);
						break
						end
					OUTPUTBOX.String = strcat('Unstable filament detected, READ no',32,num2str(runnum));
					fprintf('Unstable filament detected, READ no %d\n',runnum);
					runnum = runnum+1;
					end
				toc												%timing
				OUTPUTBOX.String = strcat('The filament was stable for',32,num2str(runnum),'READ cycles');
				fprintf('The filament was stable for %d\n',runnum);
				break
				end
			amount_of_noSET = amount_of_noSET +1;
			if amount_of_noSET == 5
				f1_voltage = f1_voltage+addition;							%VOLTAGE STEP
				amount_of_noSET = 0;
				end
			runnum = runnum+1;
			end
		setvalue = strcat(setcommand,32,SET);							%RESET TO INITIAL VOLTAGE
		end
	
	function Stat_cycle(src,event)
		%Folder creation
		if ~exist('Stat_cycle', 'dir')
		mkdir('Stat_cycle');
			end
		runnum=1;
		i = 0;					%SET Pulse counter
		j = 0;					%READ1 Pulse counter
		k = 0;					%RESET Pulse counter
		init_voltage = str2double(SET);
		init_neg_voltage = str2double(RESET);
		f1_voltage = init_voltage;
		f2_voltage = init_neg_voltage;
		addition = 0.1;
		
		row = 1;				%row of setreset_fail
		setreset_fail = [];
		resistance_log = [];
		fid = fopen('Stat_cycle\Log.txt', 'w+');
		fid2 = fopen('Stat_cycle\Resistance.txt', 'w+');
		
%		index2 = 253;
%		index1 = 226;
		x = linspace(0,200E-6,502)';
		x = x*1000000;	%make x in microseconds
		
		while get(src,'Value')															%MAIN Cycle start
			Succesful_SET_finish = 0;			%Indicator of a correctly finished SET cycle
			set_pulse_amount = 0;
						
			while get(src,'Value') == 1 & Succesful_SET_finish == 0				%SET Cycle start
				if	i == 5 | j ==5		%increase SET voltage after 5 unsuccesful pulses
					f1_voltage = f1_voltage+addition;
					i = 0;
					j = 0;
					fprintf('SET voltage increased to %d\n',f1_voltage);
					end
					
				fprintf(obj2, strcat(':PULS:WIDT',32,'15E-6'));			%setting conditions for pulsewidth
				fprintf(obj1, strcat('tdiv',32,'2E-6'));
				fprintf(obj1, strcat('trse INTV,SR,C3,HT,IL,HV,','100E-6'));
				pause(0.5)	
				
				setvalue = strcat(setcommand,32,num2str(f1_voltage)); 
				%- - - - - - - - - - SET - - - - - - - - - -
				[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = SET_PROCESS(obj1,obj2,setvalue);
				ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				[R_mem1] = resistance_calculation(ch1_data,ch3_data,50000);
				ylim(ax,[-0.5 4.5]);
				plot(ax,x,ch1_data,'y',x,ch3_data,'c');
				plot(ax2,x,R_mem1,'y');
				save_file('_Stat_cycle_SET','Stat_cycle',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
				pause(0.01)
				OUTPUTBOX.String = strcat('Stat_cycle SET no',32,num2str(runnum));
				fprintf('Stat_cycle SET no %d\n',runnum);
				runnum = runnum+1;
%				failread_trigger = fail_check_50k(ch1_data,ch3_data,'SET',index1,index2);
%				if failread_trigger == 1									%IF SET is succesful
				set_pulse_amount = set_pulse_amount+1;
					pause(1)						%time to check for self destruction of filament
					
					fprintf(obj2, strcat(':PULS:WIDT',32,'100E-6'));			%setting conditions for pulsewidth
					fprintf(obj1, strcat('tdiv',32,'20E-6'));
					fprintf(obj1, strcat('trse INTV,SR,C3,HT,IL,HV,','100E-6'));
					
%					i = 0;		%reset of i counter
					%- - - - - - - - - - READ - - - - - - - - - -
					[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);
					ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					[R_mem1] = resistance_calculation(ch1_data,ch3_data,50000);
					ylim(ax,[-0.02 0.2]);
					plot(ax,x,ch1_data,'y',x,ch3_data,'c');
					plot(ax2,x,R_mem1,'y');	
					failread_trigger = fail_check(ch1_data,ch3_data,'READ1_50k',index1,index2);
					runnum = runnum+1;
					if failread_trigger == 0							%If everything is fine
						save_file('_Stat_cycle_READ1','Stat_cycle',num2str(runnum-1),x,ch1_data,ch3_data,R_mem1,R_load);
						OUTPUTBOX.String = 'READ1 succesful';
						fprintf('READ1 succesful');
%						j = 0;		%reset of j counter
						Succesful_SET_finish = 1;
%						else
%						j = j+1;
						end
					pause(1)
%					end %end of READ1
				if Succesful_SET_finish == 1
					f1_voltage = init_voltage;
					i = 0;
					else
					i = i+1;
					end
				if f1_voltage >= 4 & i ==5 & Succesful_SET_finish == 0
%					OK_button('SET voltage is too high, continue?')
%					Ok_prompt.Visible = 'off';
					i = 0;
					end
				end	%end of SET
			
			Succesful_RESET_finish = 0;			%Indicator of a correctly finished RESET cycle
			setreset_fail(row,1) = set_pulse_amount;
			resistance_log(row,1) = R_mem1(250);
			reset_pulse_amount = 0;
	
			while get(src,'Value') == 1 & Succesful_RESET_finish == 0
				if	k == 2			%increase SET voltage after 5 unsuccesful pulses
					f2_voltage = f2_voltage-(addition*5);
					k = 0;
					fprintf('RESET voltage increased to %d\n',f2_voltage);
					end
					
				fprintf(obj2, strcat(':PULS:WIDT',32,'3E-6'));
				fprintf(obj1, strcat('tdiv',32,'0.5E-6'));
				fprintf(obj1, strcat('trse INTV,SR,C3,HT,IL,HV,','3E-6'));
					
				resetvalue = strcat(resetcommand,32,num2str(f2_voltage)); 		%INITIAL VOLTAGE
				pause(0.5)
				%- - - - - - - - - - RESET - - - - - - - - - -
				[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = RESET_PROCESS(obj1,obj2,resetvalue);             %See function RESET_PROCESS
				ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				[R_mem1] = resistance_calculation(ch1_data,ch3_data,1000);
				ylim(ax,[-4.5 0.5]);
				plot(ax,x,ch1_data,'y',x,ch3_data,'c');
				plot(ax2,x,R_mem1,'y');
				save_file('_Stat_cycle_RESET','Stat_cycle',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
				OUTPUTBOX.String = strcat('Stat_cycle RESET no',32,num2str(runnum));
				fprintf('Stat_cycle RESET no %d\n',runnum);
				runnum = runnum+1;
				reset_pulse_amount = reset_pulse_amount+1;
%				failread_trigger = fail_check_50k(ch1_data,ch3_data,'SET',index1,index2);
%				if failread_trigger == 1									%IF RESET is succesful
					pause(1)
%					k = 0;			%reset of k counter

					fprintf(obj2, strcat(':PULS:WIDT',32,'100E-6'));
					fprintf(obj1, strcat('tdiv',32,'20E-6'));
					fprintf(obj1, strcat('trse INTV,SR,C3,HT,IL,HV,','100E-6'));
					
					pause(0.5)
					%- - - - - - - - - - READ - - - - - - - - - -
					[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);
					ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					[R_mem1] = resistance_calculation(ch1_data,ch3_data,50000);
					ylim(ax,[-0.02 0.2]);
					plot(ax,x,ch1_data,'y',x,ch3_data,'c');
					plot(ax2,x,R_mem1,'y');	
					failread_trigger = fail_check(ch1_data,ch3_data,'READ2_50k',index1,index2);
					runnum = runnum+1;
					if failread_trigger == 0							%If everything is fine
						save_file('_Stat_cycle_READ2','Stat_cycle',num2str(runnum-1),x,ch1_data,ch3_data,R_mem1,R_load);
						OUTPUTBOX.String = 'READ2 succesful';
						fprintf('READ2 succesful');
						Succesful_RESET_finish = 1;
						end
					pause(1)
%					end		%end of READ2
				if Succesful_RESET_finish == 1
					f2_voltage = init_neg_voltage;
					else
					k = k+1;
					end
				if	f2_voltage == -4 & k == 2			%Change resistor case
%					OK_button('Decrease the Load resistor and press OK')
%					Ok_prompt.Visible = 'off';
					f2_voltage = init_neg_voltage;
					k = 0;
					end
				end			%end of RESET cycle
			setreset_fail(row,2) = reset_pulse_amount;
			resistance_log(row,2) = R_mem1(250);
			row = row+1;
			fprintf(fid,'%d %d\n',setreset_fail);
			fprintf(fid2,'%d %d\n',resistance_log);
			end				%end of Main While cycle
		%- - - - - - - - - - Final Message - - - - - - - - - -
		OUTPUTBOX.String = strcat('Program finished, with amount of runs =',32,num2str(runnum));
		fprintf('Program finished, with amount of runs = %d\n',runnum);
		fid = fclose(fid);
		fid2 = fclose(fid2);
		end
	
	function Stat_cycle_low_res(src,event)
		%Folder creation
		if ~exist('Stat_cycle_low_res', 'dir')
		mkdir('Stat_cycle_low_res');
			end
		%data filtering
		windowSize = 50;
		filt = (1/windowSize)*ones(1,windowSize);
		%
		runnum=1;
		row = 1;				%row of setreset_fail
		setreset_fail = [];
		fid = fopen('Stat_cycle_low_res\Log.txt', 'w+');
%		i = 0;					%SET Pulse counter
%		j = 0;					%READ1 Pulse counter
		k = 0;					%RESET Pulse counter
		init_voltage = str2double(SET);
		f1_voltage = init_voltage;
		f2_voltage_init = str2double(RESET);
		f2_voltage = f2_voltage_init;
		addition = 0.1;
		while get(src,'Value')															%MAIN Cycle start
			Succesful_SET_finish = 0;			%Indicator of a correctly finished SET cycle
			set_pulse_amount = 0;
			while get(src,'Value') == 1 & Succesful_SET_finish == 0				%SET Cycle start
%				if	i == 5 | j ==5			%increase SET voltage after 5 unsuccesful pulses
%					f1_voltage = f1_voltage+addition;
%					i = 0;
%					j = 0;
%					fprintf('SET voltage increased to %d\n',f1_voltage);
%					end
				setvalue = strcat(setcommand,32,num2str(f1_voltage)); 
				%- - - - - - - - - - SET - - - - - - - - - -
				[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = SET_PROCESS(obj1,obj2,setvalue);
				ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
				plot(ax,x,ch1_data,'y',x,ch3_data,'c');
				plot(ax2,x,R_mem1,'y');
				save_file('_Stat_cycle_SET','Stat_cycle_low_res',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
				pause(0.01)
				OUTPUTBOX.String = strcat('Stat_cycle SET no',32,num2str(runnum));
				fprintf('Stat_cycle SET no %d\n',runnum);
				runnum = runnum+1;
				set_pulse_amount = set_pulse_amount+1;
					pause(1)						%time to check for self destruction of filament
%					i = 0;		%reset of i counter
					%- - - - - - - - - - READ - - - - - - - - - -
					[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);
					ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
					ch1_data = filter(filt,1,ch1_data);
					plot(ax,x,ch1_data,'y',x,ch3_data,'c');
					plot(ax2,x,R_mem1,'y');	
					failread_trigger = fail_check_low_R(ch1_data,ch3_data,'READ1',(index1-30),(index2-30));
					runnum = runnum+1;
					save_file('_Stat_cycle_READ1','Stat_cycle_low_res',num2str(runnum-1),x,ch1_data,ch3_data,R_mem1,R_load);
					if failread_trigger == 0							%If everything is fine
						OUTPUTBOX.String = 'READ1 succesful';
						fprintf('READ1 succesful');
%						j = 0;		%reset of j counter
						Succesful_SET_finish = 1;
%						else
%						j = j+1;
						end
%				if Succesful_SET_finish == 1
%					f1_voltage = init_voltage;
%					else
%					i = i+1;
%					end
%				if f1_voltage >= 4 & i ==5 & Succesful_SET_finish == 0
%					OK_button('SET voltage is too high, continue?')
%					Ok_prompt.Visible = 'off';
%					i = 0;
%					end
				end	%end of SET
			pause(0.2)
			setreset_fail(row,1) = set_pulse_amount;
			Succesful_RESET_finish = 0;			%Indicator of a correctly finished RESET cycle
			reset_pulse_amount = 0;
			while get(src,'Value') == 1 & Succesful_RESET_finish == 0
				if	k == 5 & f2_voltage <= 5			%increase RESET voltage after 5 unsuccesful pulses
					f2_voltage = f2_voltage-(addition*5);
					k = 0;
					fprintf('RESET voltage increased to %d\n',f2_voltage);
					end
				resetvalue = strcat(resetcommand,32,num2str(f2_voltage)); 		%INITIAL VOLTAGE
				%- - - - - - - - - - RESET - - - - - - - - - -
				[ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = RESET_PROCESS(obj1,obj2,resetvalue);             %See function RESET_PROCESS
				ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
				[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
				plot(ax,x,ch1_data,'y',x,ch3_data,'c');
				plot(ax2,x,R_mem1,'y');
				save_file('_Stat_cycle_RESET','Stat_cycle_low_res',num2str(runnum),x,ch1_data,ch3_data,R_mem1,R_load);
				OUTPUTBOX.String = strcat('Stat_cycle RESET no',32,num2str(runnum));
				fprintf('Stat_cycle RESET no %d\n',num2str(runnum));
				runnum = runnum+1;
				reset_pulse_amount = reset_pulse_amount+1;
					pause(1)
					%- - - - - - - - - - READ - - - - - - - - - -
					[ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = READ_PROCESS(obj1,obj2,readvalue);
					ch1_data=save_oscilloscope(obj1, 'c1',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					ch3_data=save_oscilloscope(obj1, 'c3',data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset);
					[R_mem1] = resistance_calculation(ch1_data,ch3_data,R_load);
					ch1_data = filter(filt,1,ch1_data);
					plot(ax,x,ch1_data,'y',x,ch3_data,'c');
					plot(ax2,x,R_mem1,'y');	
					failread_trigger = fail_check_low_R(ch1_data,ch3_data,'READ2',(index1-30),(index2-30));
					runnum = runnum+1;
					save_file('_Stat_cycle_READ2','Stat_cycle_low_res',num2str(runnum-1),x,ch1_data,ch3_data,R_mem1,R_load);
					if failread_trigger == 0							%If everything is fine
						OUTPUTBOX.String = 'READ2 succesful';
						fprintf('READ2 succesful');
						Succesful_RESET_finish = 1;
						end
				if Succesful_RESET_finish == 1
					f2_voltage = f2_voltage_init;
					k = 0;
					else
					k = k+1;
					end
%				if	f2_voltage == -3.5 & k == 2			%Change resistor case
%					OK_button('Decrease the Load resistor and press OK')
%					Ok_prompt.Visible = 'off';
%					f2_voltage = -2;
%					k = 0;
%					end
				pause(0.2)
				end			%end of RESET cycle
			setreset_fail(row,2) = reset_pulse_amount;
			row = row+1;
			fprintf(fid,'%d %d\n',setreset_fail);
			end				%end of Main While cycle
		%- - - - - - - - - - Final Message - - - - - - - - - -
		OUTPUTBOX.String = strcat('Program finished, with amount of runs =',32,num2str(runnum));
		fprintf('Program finished, with amount of runs = %d\n',runnum);
		fid = fclose(fid);
		end
	
	
	function RUNSTOP_function(src,event)
		i = 0;
		index1
		index2
		while get(src,'Value')
			i=i+1;
			pause(0.1)
			OUTPUTBOX.String = strcat('i =',32,num2str(i));
			end
		end
		
		
	
	function retrieve_SET(src,event)
		SET = get(src,'string');
		setvalue = strcat(setcommand,32,SET);
		OUTPUTBOX.String = strcat('SET changed to',32,SET);
		fprintf('SET changed to %s\n',SET);
		end	
	
	function retrieve_READ(src,event)
		READ = get(src,'string');
		readvalue = strcat(setcommand,32,READ);
		OUTPUTBOX.String = strcat('READ changed to',32,READ);
		fprintf('READ changed to %s\n', READ);
		end
	
	function retrieve_RESET(src,event)
		RESET = get(src,'string');
		resetvalue = strcat(resetcommand,32,RESET);
		OUTPUTBOX.String = strcat('RESET changed to',32,RESET);
		fprintf('RESET changed to %s\n',RESET);
		end
	
	function retrieve_rise_fall_time(src,event)
		rise_fall_time = get(src,'string');
		fprintf(obj2, strcat(':PULS:TRAN1',32,rise_fall_time,32,Pulse_width_units));                  %Leading edge
		pause(0.1)
		fprintf(obj2, strcat(':PULS:TRAN1:TRA',32,rise_fall_time,32,Pulse_width_units));              %Trailing edge
		pause(0.1)
		OUTPUTBOX.String = strcat('Rise time changed to',32,rise_fall_time);
		fprintf('Rise time changed to %s\n',rise_fall_time);
		end
	
	function retrieve_Width(src,event)
		Pulse_width = get(src,'string');
		Pulse_width = strcat(Pulse_width,Pulse_width_units);
		OUTPUTBOX.String = strcat('Pulse width changed to',32,Pulse_width);
		fprintf('Pulse width changed to %s\n',Pulse_width);
		Pulse_width = strcat(':PULS:WIDT',32,Pulse_width);
		fprintf(obj2, Pulse_width);
		Pulse_width = get(src,'string');
		
		index2 = floor(0.04*(real_data_points-2)+((real_data_points-2)/(10*scope_timescale))*str2double(Pulse_width));	%indexes for analysis
		index1 = index2-((real_data_points-2)/10);
		end
		
	function retrieve_scope_timescale(src,event)   %x is correct for 20us. needs to change
		scope_timescale = get(src,'string');
		if strcmp(Pulse_width_units,'us')
			units='E-6';
			elseif strcmp(Pulse_width_units,'ms')
			units='E-3';
			elseif strcmp(Pulse_width_units,'ns')
			units='E-9';
			elseif strcmp(Pulse_width_units,'s')
			units='';
		end
		scope_timescale1=strcat(scope_timescale,units);
		scope_timescale1=strcat('tdiv',32,scope_timescale1);
		Pulse_width1=strcat(Pulse_width,units);
		Pulse_width1=strcat('trse INTV,SR,C3,HT,IL,HV,',Pulse_width1);
		fprintf(obj1, scope_timescale1);
		fprintf(obj1, Pulse_width1);
		OUTPUTBOX.String = strcat('Scope timescale changed to',32,scope_timescale1);
		fprintf('Scope timescale changed to %s\n',scope_timescale1);
		scope_timescale = str2double(scope_timescale);

		fprintf(obj1, 'trmd auto');
		pause(1);
		fprintf(obj1, 'trmd stop');
		fprintf(obj1, 'c1:wf? dat1');
		data_points = fread(obj1, 16);
		data_points(1:8) = [];
		data_points = str2double(char(transpose(data_points)));
		if data_points>16384
			fprintf('Data points exceed inputbuffersize');
			OUTPUTBOX.String = 'Data points exceed inputbuffersize';
			end
		real_data_points = data_points/2;
		full_scope_time = scope_timescale*10*10^(-6);
		%time_quant = full_scope_time/real_data_points;
		index2 = floor(0.04*(real_data_points-2)+((real_data_points-2)/(10*scope_timescale))*str2double(Pulse_width));	%indexes for analysis
		index1 = index2-((real_data_points-2)/10);
		x = linspace(0,full_scope_time,real_data_points)';
		x = x*1000000;	%make x in microseconds
		end
		
	
	function retrieve_fileno(src,event)
		measurementnum = str2double(get(src,'string'));
		OUTPUTBOX.String = strcat('File number changed to',32,num2str(measurementnum));
		fprintf('File number changed to %s\n',num2str(measurementnum));
		end
	

	function retrieve_Resistance(src,event)
		R_load = str2double(get(src,'string'));
		OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
		fprintf('Load Resistor changed to %d\n',R_load);
		end

	function connect_instr(src,event)
		button_state = get(src,'Value');
		if button_state == 1
			Connect_button.BackgroundColor = 'g';
			fopen([obj1 obj2]);
			obj1.Timeout=1;
			fprintf('Instrument connected \n');
			Connect_button.String = 'Instruments connected';
			else 
			fclose([obj1 obj2]);
			fprintf('instrument disconnected \n');
			Connect_button.BackgroundColor = 'r';
			Connect_button.String = 'Instruments disconnected';
			end
		end

	function my_closereq(src,callbackdata)
		% Close request function 
		selection = questdlg('Close The Program?',...
		'',...
		'Yes','No','Yes'); 
		switch selection 
			case 'Yes'
			fclose([obj1 obj2]);
			fprintf('instrument disconnected \n');
			delete(gcf)
%			fid3 = fclose(fid3);
			case 'No'
			return
			end
		end
		
	function keydetect(src,event)
		switch event.Key
			case 'q'
				setbutton;
			case 'w'
				readbutton;
			case 'e'
				resetbutton;
			case 'p'
				R_load = 500000;
				Resistance_value.String = '500000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'l'
				R_load = 200000;
				Resistance_value.String = '200000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'period'
				R_load = 100000;
				Resistance_value.String = '100000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'o'
				R_load = 50000;
				Resistance_value.String = '50000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'k'
				R_load = 10000;
				Resistance_value.String = '10000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'm'
				R_load = 5000;
				Resistance_value.String = '5000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'i'
				R_load = 2000;
				Resistance_value.String = '2000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'j'
				R_load = 1000;
				Resistance_value.String = '1000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'n'
				R_load = 500;
				Resistance_value.String = '500';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			case 'u'
				R_load = 200;
				Resistance_value.String = '5000';
				OUTPUTBOX.String = strcat('Load Resistor changed to',32,num2str(R_load));
				fprintf('Load Resistor changed to %d\n',R_load);
			end
		end
	
	function save_parameters_file
		dlmwrite(filenam,[str2double(Pulse_width),str2double(rise_fall_time),str2double(slope),str2double(SET),str2double(RESET),R_load],'-append','delimiter','\t','precision','%.3f');
		end

	end