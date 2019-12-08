function generator_setup(object,Pulse_width,Pulse_width_units)

if strcmp(Pulse_width_units,'us')
units='E-6';
elseif strcmp(Pulse_width_units,'ms')
units='E-3';
elseif strcmp(Pulse_width_units,'ns')
units='E-9';
elseif strcmp(Pulse_width_units,'s')
units='';
end

Pulse_width=strcat(Pulse_width,units);
Pulse_width=strcat(':PULS:WIDT',32,Pulse_width);
fopen(object);
object.Timeout=1;
%fprintf(object, ':disp off');                            %Switch off the automatic update of the display to increase the programming speed
pause(0.1)
fprintf(object, ':SYST:CHEC OFF');                       %It is possible to switch off the error check system to increase programming speed
pause(0.1)
fprintf(object, ':ARM:SOUR INT2');                        %continuous mode		alternative -INT (PLL)			was IMM
pause(0.1)
fprintf(object, ':ARM:PER 0.02');						%PLL period                        
pause(0.1)
%fprintf(object, ':TRIGger:PATT ');                    %single pulse per period
pause(0.1)
fprintf(object, ':TRIG:SOUR INT1');                      %internal 1=osc 2=PLL
pause(0.1)
fprintf(object, 'DIG:SIGN:FORM RZ');                     %pattern mode
pause(0.1)
fprintf(object, 'DIG:PATT ON');
pause(0.1)
fprintf(object, 'DIG:PATT:UPD ON');                    % UPD
pause(0.1)
fprintf(object, ':puls:per 0.1s');                     %Period
pause(0.1)
fprintf(object, ':PULS:TRAN1 150 ns');                  %Leading edge
pause(0.1)
fprintf(object, ':PULS:TRAN1:TRA 150 ns');              %Trailing edge
pause(0.1)
fprintf(object, Pulse_width);                    %Pulse WIDTH
pause(0.1)
fprintf(object, ':PULS:del1 40 PCT');                   %pulse delay in %

fclose(object);