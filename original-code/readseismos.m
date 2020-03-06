
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% READ SYNTHETIC SEISMOGRAMS IN A FOLDER
% SHITE LOAD OF EM
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear all; %close all

path = '~/SPECFEM2D/EXAMPLES/colin/trial14/';


fidZ = fopen([path 'seisZ.txt'],'r')
seisZ = textscan(fidZ,'%s');
fidX = fopen([path 'seisX.txt'],'r');
seisX = textscan(fidX,'%s');
fclose all;

seisZ = seisZ{1};
seisX = seisX{1};

shotZ = [];
shotX = [];

if 1==1;
for i = 1:length(seisZ)

    filein = [path seisZ{i}];
    trace = readseis(filein);
    if i == 1
        tz = cell2mat(trace(1));
    end
    shotZ(:,i) = cell2mat(trace(2));
end
for i = 1:length(seisX)

    filein = [path seisX{i}];
    trace = readseis(filein);
    if i == 1
        tx = cell2mat(trace(1));
    end
    shotX(:,i) = cell2mat(trace(2));
end
end

%%
recline = [73 133];

figure
hold on
for k = recline(1):recline(2)
    shft = 0.5*max(max(shotZ(:,recline(1):recline(2))));
    plot(tz,shotZ(:,k)-shft*(k-1))
end
title('Z component')
xlabel('time (s)')


figure
hold on
for k = recline(1):recline(2)
    shft = 0.5*max(max(shotX(:,recline(1):recline(2))));
    plot(tx,shotX(:,k)-shft*(k-1))
end
title('X component')
xlabel('time (s)')




