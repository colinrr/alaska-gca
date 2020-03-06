% function densitytickPlot(x,dims)
% rangetick(X)
%  x  = input data, [m x n]: m observations, n variables
%

% toy x
n  = 101;
x1 = linspace(1,10,n);
x2 = x1.^3/5;
x3 = 3*x1.^1/2;
% x = [x1' x2' x3'];

plt = plot(x1,x2,'.');
% Some initial params for automating the whole thing with multiple
% variables. Holding off on that for now
% numvars  = size(x,2);
% N        = size(x,1);
% pairs    = nchoosek(1:numvars,2);
% numplots = size(pairs,1);
% 
% % Use number of pairs with 1st var as row dimension
% nrows    = numel(find(pairs(:,1)==1));
% ncols    = ceil(numplots/nrows);
% 
% % Density plot relative sizing
% size

%% Assume existing plot

% density plot thickness (pixels)
tpix = 10;

% Data size threshold
dthresh = 20;
% Get plot data
x = get(plt,'XData');
y = get(plt,'YData');

% Axes limits
xl = xlim;
yl = ylim;
% Calc densitites


ax = gca;

if length(x)<=dthresh
    % Place ticks for all points
    set(ax,'XTick',x,'YTick',y)
    % Place labels based on density (cumsum(diff())?
    
else
    % Get position
    set(ax,'Units','pixels')
    pos = get(gca,'position');
end