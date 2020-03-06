
statlist = '/home/crowell/mycode/statnoms.txt';
AK_stations = textread(statlist,'%s');

uafnet = '/home/ywang/alaska/data/Stations/bb_stations_complete.txt'; 
[stnm,~,~,~,~,~] = textread(uafnet,'%s%f%f%s%s%s');


count = 0;
missing = {};
for kk=1:length(AK_stations)
    check = find(strcmp(stnm,AK_stations{kk}));
    if isempty(check)
        count = count + 1;
        missing{count} = AK_stations{kk};
    end
end

fout = fopen('~/mycode/missing.txt','w');
for j = 1:length(missing)
fprintf(fout,'%s\n',missing{j});
end

fclose all