
function [sgram] = readseis(filein);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%
%   READ SPECFEM2D seismogram
%________________________________________


fid = fopen(filein,'r');
sgram = textscan(fid,'%f %f');

fclose(fid);

end
