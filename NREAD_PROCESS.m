function [ch1_offset,ch1_gain,ch2_offset,ch2_gain,ch3_gain,ch3_offset] = NREAD(object1,object2,readvalue)
	fprintf(object1, 'trmd single');
	fprintf(object2, ':OUTP1:POL INV');
	fprintf(object1, 'c3:TRSL NEG');  
%	pause(0.1)
	fprintf(object1, 'c1:ofst 0.015');             %READ offset level
	ch1_offset=0.15;
%	pause(0.1)
	fprintf(object1, 'c1:vdiv 5E-3')               %change GAIN of CH1 to oversee full signal
	fprintf(object2, ':VOLT1:HIGH -0.032');
	ch1_gain=0.005;
	fprintf(object1, 'c3:vdiv 5E-2')
	ch3_gain=0.05;
	fprintf(object1, 'c2:vdiv 2E-3')              
	ch2_gain=0.002;
	fprintf(object1, 'c2:ofst 0.0065');             %READ offset level CH2
	ch2_offset=0.065;
%	pause(0.1)
	fprintf(object1, 'c3:ofst 0.15');             %READ offset level
	ch3_offset=0.15;
	fprintf(object2, strcat(':VOLT1:LOW',32,'-',readvalue(13:end)));
	fprintf(object1, 'trlv -0.1');                  %READ trigger level
%	pause(1)
	fprintf(object2, ':OUTP1 1');
		while 1
			stop_trigger=query(object1, 'TRMD?');
			stop_trigger=stop_trigger(~isspace(stop_trigger));
				if strcmp('STOP', stop_trigger)
					break
				end
		end
	fprintf(object2, ':OUTP1 0');
	fprintf(object1, 'c3:TRSL POS');