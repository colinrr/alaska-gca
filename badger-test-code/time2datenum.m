function[tOut] = time2datenum(tIn,units)
%  [t] = time2datenum(t,units)
%  Quick function to convert a non-referenced time or time vector to
%  datenum format
%
%  INPUT:  tIn    = time vector
%          units  = 'seconds', 'minutes', 'hours', 'days', 'months','years'
%                   --> Use 'months' with caution, as the datenum format
%                       assumes a specific month of the year
%          tOut   = time vector in datenum format
%
% C Rowell Jun 2017
%

if units=='seconds'
    ii = 6;
elseif units=='minutes'
    ii = 5;
elseif units=='hours'
    ii=4;
elseif units=='days'
    ii=3;
elseif units=='months'
    ii=2;
elseif units=='years'
    ii=1;
end

datemat = zeros(numel(tIn),6);
datemat(:,ii) = tIn;

tOut = datenum(datemat);