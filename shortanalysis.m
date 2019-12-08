oldfolder = cd;
path = '';
[filename,path] = uigetfile('../*.txt');
cd(path);
data = importdata(filename);
points = size(data);
cycles = points(1,1)/10;
read1 = [];
read2 = [];
set = [];
reset = [];
row = 1 ;
for cyclenum = 0:cycles-1;
	read1(row,1) = data(5+10*cyclenum);
	read2(row,1) = data(9+10*cyclenum);
	set(row,1) = data(3+10*cyclenum);
	reset(row,1) = data(7+10*cyclenum);
	row = row +1;
	end
read1 = abs(read1);
read2 = abs (read2);
set = abs(set);
reset = abs(reset);
Ron = 0.3./read1;
Roff = 0.3./read2;
dlmwrite(strcat(path,filename,'Ron.txt'),Ron);
dlmwrite(strcat(path,filename,'Roff.txt'),Roff);
cd(oldfolder);