function waveform_binary = save_osc(obj,chano,data_points,ch1_attn,ch1_gain,ch1_offset,ch2_attn,ch2_gain,ch2_offset,ch3_attn,ch3_gain,ch3_offset)
%This function outputs signal as waveform_binary
%List of channels: c1 c2 c3 c4 TA TB TC TD
%multiply by gain and offset externally
%example: ch1_data=waveform_binary*ch1_gain/32-ch1_offset;

channel_no = strcat(chano,':WF? dat1');
		waveform_binary = [];
		fprintf(obj, channel_no);
		waveform_binary = fread(obj,(data_points+16));
		waveform_binary(1:16)=[];                             	      %remove descriptor
		waveform_binary(end)=[];                               		  %remove lastbit
		waveform_binary(2:2:end,:)=[];                                %remove every second zero
		waveform_binary=uint8(waveform_binary);                       %matblab reads binary as double, so we fix it
		waveform_binary=typecast(waveform_binary,'int8');             %turn it into signed word
		waveform_binary=double(waveform_binary);                      %turn data to decimal
		if strcmp('c1', chano)
			waveform_binary=waveform_binary*ch1_attn*ch1_gain/32-ch1_offset;
		elseif strcmp('c2', chano)
			waveform_binary=waveform_binary*ch2_attn*ch2_gain/32-ch2_offset;
		elseif strcmp('c3', chano)
			waveform_binary=waveform_binary*ch3_attn*ch3_gain/32-ch3_offset;
		elseif strcmp('c4', chano)
			waveform_binary=waveform_binary*ch4_attn*ch4_gain/32-ch4_offset;
		end