function failread = analysis(ch_data,ch3_data,PROCESS,index1,index2)
%failread = 1 means a failure of READ operation
failread = 0;
if strcmp('READ1', PROCESS)
 	for signalindex = index1 : index2
		if ch_data(signalindex) < 0.9*ch3_data(signalindex)                                    %read1 fail condition
			failread=1;
		end;
	end;
elseif strcmp('READ2', PROCESS)
	for signalindex = index1 : index2
		if ch_data(signalindex) > 0.9*ch3_data(signalindex)                                %read1 fail condition
			failread=1;
		end;
	end;
elseif strcmp('SET', PROCESS)
	if ch_data(index2-5) > 0.9*ch3_data(index2-5)                                     %SET fail condition
		failread=1;
	end;
elseif strcmp('READ1_50k', PROCESS)
 	for signalindex = 226 : 253
		if ch_data(signalindex) < 0.6*ch3_data(signalindex)                                    %read1 fail condition
			failread=1;
		end;
	end;
elseif strcmp('READ2_50k', PROCESS)
	for signalindex = 226 : 253
		if ch_data(signalindex) > 0.3*ch3_data(signalindex)                                %read1 fail condition
			failread=1;
		end;
	end;
end;