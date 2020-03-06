function showEventParams(E)
% E = event params
% w = waveforms

fprintf('Volcano:\t%s\nEvent:\t\t%s\n',E.volcano,num2str(E.enum))
fprintf('Start time:\t%s\n',E.tStart)
fprintf('Search radius:\t%i\n',E.radius)

chstrings = {'Network','Station','Location','Channel'};
fprintf('Station Input:\n')
for i = 1:length(E.station_params)
    fprintf('  %s:\t%s\n',chstrings{i},strjoin(E.station_params{i},', '))
end

if isfield(E,'Nchannels')
fprintf('%i Channels, %i Stations, %i Networks\n',...
    E.Nchannels,...
    E.Nstations,...
    E.Nnetworks)
end