function [ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = RESET(object1,object2,resetvalue)
	fprintf(object1, 'trmd single');
	fprintf(object2, ':OUTP1:POL INV');
	fprintf(object1, 'c1:ofst 0.015');             %READ offset level
	ch1_offset=0.15;
	fprintf(object1, 'c2:ofst 0.03');           %RESET offset level CH2 change to neg
	ch2_offset=0.3;
%	pause(0.1)
	fprintf(object1, 'c1:vdiv 5E-3');               %change GAIN of CH1 to oversee full signal
	ch1_gain=0.005;
	fprintf(object1, 'c2:vdiv 1E-2');              
	ch2_gain=0.01;
	fprintf(object1, 'c3:vdiv 1');              
	ch3_gain=1;	
	fprintf(object1, 'c3:ofst 3');           %RESET offset level CH2 change to neg
	ch3_offset=3;
	fprintf(object2, ':VOLT1:HIGH -0.025');
	fprintf(object1, 'c3:TRSL NEG');               %Negative trigger slope
%	pause(0.1)
	fprintf(object2, resetvalue);
	fprintf(object1, 'trlv -0.4');                  %RESET trigger level
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
	fprintf(object1, 'c3:TRSL POS');               %Positive trigger slope (going back)