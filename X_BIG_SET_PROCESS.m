function [ch1_offset,ch2_offset,ch1_gain,ch2_gain,ch3_gain,ch3_offset] = SET(object1,object2,setvalue)
	fprintf(object1, 'trmd single');
	ch1_offset=-1.5;
	fprintf(object2, ':OUTP1:POL NORM');
	fprintf(object1, 'c1:ofst -0.15');              %SET offset level
%	pause(0.1)
	fprintf(object1, 'c2:ofst -0.06');             %READ offset level CH2
	fprintf(object2, ':VOLT1:LOW -0.000');
	ch2_offset=-0.6;
	fprintf(object1, 'c1:vdiv 5E-2')               %change GAIN of CH1 to oversee full signal
	ch1_gain=0.05;
	fprintf(object1, 'c3:vdiv 1');
	ch3_gain=1;
	ch2_gain=0.02;
	fprintf(object1, 'c2:vdiv 2E-2')
	fprintf(object1, 'c3:ofst -3');  
	ch3_offset=-3;
%	pause(0.1)
	fprintf(object2, setvalue);
	fprintf(object1, 'trlv 0.15');                  %SET trigger level
%	pause(1)
	fprintf(object2, ':OUTP1 1');
		while 1
			stop_trigger=query(object1, 'TRMD?');
			stop_trigger=stop_trigger(~isspace(stop_trigger));
				if strcmp('STOP', stop_trigger)
					break
				end
%			pause(0.1)
		end
	fprintf(object2, ':OUTP1 0');