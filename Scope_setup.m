function [ch1_gain,ch2_gain,ch3_gain,ch4_gain,ch1_offset,ch2_offset,ch3_offset,ch4_offset,ch1_attn,ch2_attn,ch3_attn,ch4_attn,data_points,x] = scope_setup(object,Pulse_width,Pulse_width_units,scope_timescale)
set(object, 'InputBufferSize', 16384);

if strcmp(Pulse_width_units,'us')
units='E-6';
elseif strcmp(Pulse_width_units,'ms')
units='E-3';
elseif strcmp(Pulse_width_units,'ns')
units='E-9';
elseif strcmp(Pulse_width_units,'s')
units='';
end
scope_timescale=num2str(scope_timescale);
scope_timescale=strcat(scope_timescale,units);
scope_timescale1=strcat('tdiv',32,scope_timescale);
Pulse_width=strcat(Pulse_width,units);
Pulse_width=strcat('trse INTV,SR,C3,HT,IL,HV,',Pulse_width);
fopen(object);
object.Timeout=1;
fprintf(object, '*CLS');
fprintf(object, 'CORD HI');
fprintf(object, 'CFMT DEF9, WORD,BIN');
fprintf(object, 'CHDR OFF');
fprintf(object, 'WFSU SP,0,NP,0,FP,0,SN,0');
fprintf(object, 'c1:cpl d1m');               %set coupling  {A1M, D1M, D50, GND, OVL}
fprintf(object, 'c2:cpl d1m');               %set coupling
fprintf(object, 'trdl 4');                  %trigger delay
fprintf(object, 'c1:TRCP DC');               %trigger coupling
fprintf(object, 'c1:TRSL POS');              %Positive trigger slope
fprintf(object, scope_timescale1);
fprintf(object, Pulse_width);  %Trigger setup for Interval 10ms
%fprintf(object, 'c1:TRLV 0.117.6');          %Trigger Level
ch1_gain=query(object, 'c1:vdiv?');
ch1_gain=str2num(ch1_gain);
ch2_gain=query(object, 'c2:vdiv?');
ch2_gain=str2num(ch2_gain);
ch3_gain=query(object, 'c3:vdiv?');
ch3_gain=str2num(ch3_gain);
ch4_gain=query(object, 'c4:vdiv?');
ch4_gain=str2num(ch4_gain);
ch1_offset=query(object, 'c1:ofst?');
ch1_offset=str2num(ch1_offset);
ch2_offset=query(object, 'c2:ofst?');
ch2_offset=str2num(ch2_offset);
ch3_offset=query(object, 'c3:ofst?');
ch3_offset=str2num(ch3_offset);
ch4_offset=query(object, 'c4:ofst?');
ch4_offset=str2num(ch4_offset);
ch1_attn=query(object, 'C1:attn?');
ch1_attn=str2num(ch1_attn);
ch2_attn=query(object, 'C2:attn?');
ch2_attn=str2num(ch2_attn);
ch3_attn=query(object, 'C3:attn?');
ch3_attn=str2num(ch3_attn);
ch4_attn=query(object, 'C4:attn?');
ch4_attn=str2num(ch4_attn);
time_div=query(object, 'tdiv?');
time_div=str2num(time_div);

fprintf(object, 'trmd auto');
pause(1);
fprintf(object, 'trmd stop');
fprintf(object, 'c1:wf? dat1');
data_points = fread(object, 16);
data_points(1:8) = [];
data_points = str2double(char(transpose(data_points)));
if data_points>16384
	fprintf('Data points exceed inputbuffersize');
	end
real_data_points = data_points/2;
full_scope_time = str2double(scope_timescale)*10;
%time_quant = full_scope_time/real_data_points;
x = linspace(0,full_scope_time,real_data_points)';
x = x*1000000;	%make x in microseconds

%if time_div == 2E-7
%	time_quant=5E-10;
%elseif time_div == 2E-6
%	time_quant=4E-9;
%elseif time_div == 20E-6
%	time_quant=4E-8;
%else time_quant=time_div/500;
%	disp('check time_quant');
%end


fclose(object);