%  AIR WAVES PICKS COMPARISON AND STUFF

close all

load air_picks.mat


% Array is organized thus:

% STAT_CHAN   DIST  AZIM  tpic  cel
badnums = 24;
badpics = cell2mat(Picksb(badnums,2:end));
%Picksb(badnums,:) = [];

dist = cell2mat(Picksb(:,2));
azim = cell2mat(Picksb(:,3));
tpic = cell2mat(Picksb(:,4));
c    = cell2mat(Picksb(:,5));

Pdt = polyfit(tpic,dist,1);


% Quick plots

figure

set(gcf,'position',[100 100 900 750])
subplot(2,2,1)
scatter(tpic,dist)
hold on
scatter(badpics(:,3),badpics(:,1),'r')
plot(tpic,tpic*Pdt(1) + Pdt(2),'r');
grid on
set(gca,'FontSize',16)
text(405,30,['m = ' num2str(Pdt(1)) ' m/s'],'FontSize',16);
pause(0.1)  %THIS MAY BE THE GREATEST MATLAB MYSTERY OF ALL TIME...TRY WITHOUT THE PAUSE
text(min(get(gca,'XLim'))+diff(get(gca,'XLim'))*0.05,...
    min(get(gca,'YLim'))+diff(get(gca,'YLim'))*1.05,...
    'a','FontWeight','bold','FontSize',18)
xlabel('Time (s)')
ylabel('Distance (km)')
title('Time vs. Distance')


subplot(2,2,2)
scatter(tpic,c)
grid on
hold on
scatter(badpics(:,3),badpics(:,4),'r')
set(gca,'FontSize',16)
text(min(get(gca,'XLim'))+diff(get(gca,'XLim'))*0.05,...
    min(get(gca,'YLim'))+diff(get(gca,'YLim'))*1.05,...
    'b','FontWeight','bold','FontSize',18)
xlabel('Time (s)')
ylabel('Celerity (km/s)')
title('Arrival Time vs. Celerity')

subplot(2,2,3)
scatter(dist,c)
grid on
hold on
scatter(badpics(:,1),badpics(:,4),'r')
set(gca,'FontSize',16)
text(min(get(gca,'XLim'))+diff(get(gca,'XLim'))*0.05,...
    min(get(gca,'YLim'))+diff(get(gca,'YLim'))*1.05,...
    'c','FontWeight','bold','FontSize',18)
xlabel('Distance (km)')
ylabel('Celerity (km/s)')
title('Distance vs. Celerity')

subplot(2,2,4)
scatter(azim,c)
hold on
scatter(badpics(:,2),badpics(:,4),'r')
grid on
set(gca,'FontSize',16)
text(min(get(gca,'XLim'))+diff(get(gca,'XLim'))*0.05,...
    min(get(gca,'YLim'))+diff(get(gca,'YLim'))*1.05,...
    'd','FontWeight','bold','FontSize',18)
ylabel('Celerity (km/s)')
xlabel('Azimuth (degrees CW from North)')
title('Azimuth vs. Celerity')
