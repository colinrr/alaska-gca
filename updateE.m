function[E] = updateE(E,ss)
% [E] = updateE(E,ss)
%
    E.Nchannels = numel(ss);
    E.Nstations = numel(unique({ss.StationCode}));
    E.Nnetworks = numel(unique({ss.NetworkCode}));
    fprintf('UPDATE:\n%i Channels, %i Stations, %i Networks\n',...
        E.Nchannels,...
        E.Nstations,...
        E.Nnetworks)
end