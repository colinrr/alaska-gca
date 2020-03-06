% ds1 = datasource('antelope','/aerun/sum/db/archive/archive_2009,/archive_2009_03_23');
ds1 = datasource('uaf_continuous');
scnl = scnlobject('FOSS','*','','');
wF = waveform(ds1,scnl,t0,t0 + (60*20)/spdy);


figure
for i = 1:length(wF)
    subplot(length(wF),1,i)
    plot(wF(i))
end