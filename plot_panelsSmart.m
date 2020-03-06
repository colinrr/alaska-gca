function plot_panelsSmart(w, alignWaveforms, titlestr)
% Function to make plotting lots of panels a bit more manageable
% Plotting large waveforms in subsets to make individual figures legible
    % titlestr = optional title string to avoid confusing plots

if ~exist('alignWaveforms', 'var')
            alignWaveforms = false;
end
if exist('titlestr', 'var')
    titleflag = 1;
else
    titleflag = 0;
end

maxrows = 10; % Max number of panels per figure
Nw = numel(w);

Nrows = min([Nw maxrows]);
numfigs = ceil(Nw/maxrows);
hndls=zeros(numfigs,1);
v = 1:maxrows:Nw; % First index of each figure

for k = 1:numel(v)
    iend = min([Nw v(k)+maxrows-1]);
    plot_panels(w(v(k):iend),alignWaveforms);
    figpos = get(gcf,'Position');
    figpos(1) = 100+(k-1)*figpos(3);
    figpos(4) = 100+70*Nrows;
    set(gcf,'Position',figpos)
    if titleflag
        set(gcf,'name',titlestr)
    end
    pause(0.1)
end

